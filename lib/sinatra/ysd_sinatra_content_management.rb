require 'ui/ysd_ui_entity_management_aspect_render' unless defined?UI::EntityManagementAspectRender
require 'guiblocks/ysd_guiblock_rac'
require 'ui/ysd_ui_guiblock_entity_aspect_adapter'

module Sinatra
  module YSD
    module ContentManagement
   
      def self.registered(app)
       
        app.helpers do 
       
          #
          # Helper to get the publishing state translations
          #
          def build_publishing_state_translations
            publishing_states = {}
            ContentManagerSystem::PublishingState.all.each do |publishing_state|
              publishing_states.store(publishing_state.id, t.publishing.status[publishing_state.id.downcase.to_sym]) unless publishing_state.id.nil?
            end

            return publishing_states
          end

          #
          # Helper to get the POST publishing actions
          #
          def build_post_publishing_actions

            publishing_actions = {}
            publishing_actions.store('PEND_CONF', {:action => 'REDIRECT_TO_STATUS' , :url_prefix => '/content-status/'})
            publishing_actions.store('PUBLISHED', {:action => 'REDIRECT_TO_PUBLICATION', :url_prefix => '/content/'})

            return publishing_actions
          end

          #
          # Helper to create the new content buttons
          #
          def build_creation_buttons(available_actions)

            creation_buttons = []
            
            if available_actions.any? { |action| action == ContentManagerSystem::PublishingAction::SAVE}
              creation_buttons << {:id => 'save_content', :text => 'Save', :url => '/content?op=save', :class => 'publishing-button-save'} 
            end
            
            if available_actions.any? { |action| action == ContentManagerSystem::PublishingAction::PUBLISH }
              creation_buttons << {:id => 'publish_content', :text => 'Publish', :url  => '/content', :class => 'publishing-button-publish'} 
            end

            return creation_buttons

          end

          #
          # Get the content complements
          # 
          def render_content_type_aspects(content_type_id, content=nil)
            
            context = {:app => self}
            result = {}
                    
            if content_type = ContentManagerSystem::ContentType.get(content_type_id)
              aspects = []
              aspects.concat(content_type.aspects)
              aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::AnonymousPublishing.new, {:weight => 99, :in_group => false, :show_on_edit => false})               
              aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::PostPublishing.new, {:weight => 99, :in_group => false})                     
              unless content.nil? or content.new?
                aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::ResourceAccessControl.new(content), {:weight => 100, :in_group => true, :show_on_new => false})   
                aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::PublishingActions.new(content), {:weight => -5, :in_group => false, :show_on_new => false})      
              end
              aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::Meta.new, {:weight => 101, :in_group => true, :show_on_new => false})                               
              aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::Audit.new, {:weight => 102, :in_group => true, :show_on_new => false})                              
              aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::ContentOther.new, {:weight => -1, :in_group => false, :show_on_new => false})
              
              aspects_render = UI::EntityManagementAspectRender.new(context, aspects) 
              result = aspects_render.render(content_type)

            end            

            return result
          
          end

        end
        
        #
        # Users contents
        #
        app.get "/mycontents/?*" do

        end

        #
        # Contents management
        #
        app.get "/mcontents/?*" do
        
          if not request.accept?'text/html'
            pass
          end        

          locals = {}
          locals.store(:publishing_states, build_publishing_state_translations.to_json )        
          load_em_page(:contents, nil, false, :locals => locals)
        
        end
        
        #
        # Content creation (show all content types the user can create)
        #
        app.get "/mcontent/new/?" do
        
          load_em_page(:content_new, nil, false)
        
        end
           
        #
        # Create a new content 
        #      
        app.get "/mcontent/new/:content_type/?*" do
                    
          if content_type = ContentManagerSystem::ContentType.get(params[:content_type])
            if content_type.can_be_created_by?(user)
              blank_content = ContentManagerSystem::Content.new({:content_type => content_type, 
                               :composer_username => user.username, 
                               :publishing_state_id => ContentManagerSystem::PublishingState::INITIAL.id,
                               :publishing_workflow_id => content_type.publishing_workflow_id})

              locals = render_content_type_aspects(params[:content_type], blank_content)
              locals.store(:url_base, "/mcontent/new/#{params[:content_type]}")
              locals.store(:action, 'new')
              locals.store(:id, nil)
              locals.store(:content_type, params[:content_type])
              locals.store(:title, "#{t.entitymanagement.new} #{content_type.name.downcase}")
              locals.store(:description, content_type.message_on_new_content)
              locals.store(:creation_buttons, build_creation_buttons(blank_content.publishing_actions))
              locals.store(:publishing_actions, build_post_publishing_actions.to_json)
              locals.store(:publishing_states, build_publishing_state_translations.to_json )

              load_em_page(:content_edition, nil, false, :locals => locals)
            else
              status 401
            end
          else
            status 404
          end

        end      
        
        #
        # Edit a content
        #
        app.get "/mcontent/edit/:id/?*" do

          content = ContentManagerSystem::Content.get(params[:id])

          if content 
            if content.can_write?(user)            

              locals = render_content_type_aspects(content.content_type.id, content)
              locals.store(:url_base, "/mcontent/edit/params[:id]")
              locals.store(:action, 'edit')
              locals.store(:id, params[:id])          
              locals.store(:content_type, content.content_type.id)
              locals.store(:title, "#{t.entitymanagement.edit} #{content.content_type.name.downcase}")
              locals.store(:description, content.content_type.message_on_edit_content)
              locals.store(:publishing_actions, {}.to_json)
              locals.store(:publishing_states, build_publishing_state_translations.to_json )

              load_em_page(:content_edition, nil, false, :locals => locals)
            else
              status 401
            end
          else
            status 404        
          end

        end
        
        #
        # Public content management
        #   
        app.get "/m/:id" do

          content = ContentManagerSystem::Content.get(params[:id])

          if content.is_pending_confirmation?
            content.confirm_publication           
          end

          call! env.merge("PATH_INFO" => "/content-status/#{params[:id]}")

        end

        #
        # Get the Gui with the publishing actions 
        #
        app.get "/publishing-actions/:id" do
 
           content = ContentManagerSystem::Content.get(params[:id])

           if content 
             if content.can_write?(user)
               aspects = []
               aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::PublishingActions.new(content))
               aspects_render=UI::EntityManagementAspectRender.new({:app => self}, aspects) 
               aspects_render.render(content.content_type)[:edit_element_form]
             else
              status 401
             end
           else
             status 404
           end

        end

        #
        # Get the content status page
        #
        app.get "/content-status/:id" do
          
          content = ContentManagerSystem::Content.get(params[:id])
          
          if content 
            if content.can_write?(user)
              template = case ContentManagerSystem::PublishingState.get(content.publishing_state)
                           when ContentManagerSystem::PublishingState::PENDING_CONFIRMATION
                             'publishing-pending-confirmation'
                           when ContentManagerSystem::PublishingState::PENDING_VALIDATION
                             'publishing-pending-validation'
                           when ContentManagerSystem::PublishingState::PUBLISHED
                             'publishing-published'
                           when ContentManagerSystem::PublishingState::BANNED
                             'publishing-banned'
                         end

              load_page(template, :locals => {:element => t.content.title.downcase, 
                                          :publication => content, 
                                          :publishing_address => "/content/#{content.key}" , 
                                          :management_address => "/mcontent/edit/#{content.key}"})
            else
              status 401
            end
          else
            status 404
          end

        end

        #
        # Manages the content photos (media gallery integration)
        #
        app.get "/mcontent-mphotos/:id/?*" do

          if content = ContentManagerSystem::Content.get(params[:id])
                        
            media_album = nil
            
            if content.album_name.nil? or content.album_name.to_s.strip.length == 0
              content.album_name = "content_#{content.key}"
              content.update
            end
            
            unless media_album = Media::Album.get(content.album_name)                   
              content_type = ContentManagerSystem::ContentType.get(content.type)
              media_album = Media::Album.new(:name => content.key, 
                                             :width => content_type.aspect('album').get_aspect_attribute_value('album_photo_width').to_i, 
                                             :height => content_type.aspect('album').get_aspect_attribute_value('album_photo_height').to_i)
            end
            
            load_page('photo_management'.to_sym, :locals => {:album => media_album})
             
          else
            status 404 # the content does not exist
          end       
        
        end             
              
      end
    
    end #ContentManagement
  end #YSD
end #Sinatra