require 'ui/ysd_ui_entity_management_aspect_render' unless defined?UI::EntityManagementAspectRender
require 'guiblocks/ysd_guiblock_rac'
require 'ui/ysd_ui_guiblock_entity_aspect_adapter'

module Sinatra
  module YSD
    #
    # Content Management
    #
    module ContentManagement
   
      def self.registered(app)

        #
        # Get all pages
        #
        app.get "/admin/cms/pages", :allowed_usergroups => ['staff','webmaster']  do
          @pages = ContentManagerSystem::Content.all(conditions: { type: 'page'}, order: [:title.asc])
          load_page(:cms_pages, layout: false)
        end

        #
        # Get all posts
        #
        app.get "/admin/cms/posts", :allowed_usergroups => ['staff','webmaster']  do
          @pages = ContentManagerSystem::Content.all(conditions: { type: 'story'}, order: [:creation_date.desc])
          load_page(:cms_posts, layout: false)
        end

        #
        # New page
        # 
        app.get "/admin/cms/page-content/new", :allowed_usergroups => ['staff','webmaster']  do
           load_page(:basic_new_page)
        end

        #
        # Edit page
        # 
        app.get "/admin/cms/page-content/:id/edit", :allowed_usergroups => ['staff','webmaster']  do
           @page = ContentManagerSystem::Content.first(type: 'page', id: params[:id])
           load_page(:basic_edit_page)
        end
        
        #
        # CMS Console 
        #       
        app.get "/admin/cms", :allowed_usergroups => ['staff','editor','webmaster'] do
       
          load_page(:console_cms)

        end

        #
        # Contents management
        #
        app.get "/admin/cms/contents/?*", :allowed_usergroups => ['staff','editor','webmaster'] do
        
          if not request.accept?'text/html'
            pass
          end        

          locals = {}
          locals.store(:publishing_states, build_publishing_state_translations.to_json )        
          load_em_page(:contents, nil, false, :locals => locals)
        
        end
        
        #
        # Content creation 
        #
        # Show all content types the user can create
        #
        app.get "/admin/cms/content/new/?" do
        
          load_em_page(:content_new, nil, false)
        
        end
           
        #
        # Create a new content 
        #      
        app.get "/admin/cms/content/new/:content_type/?*" do
                    
          if content_type = ContentManagerSystem::ContentType.get(params[:content_type])
            if content_type.can_be_created_by?(user)
              blank_content = ContentManagerSystem::Content.new({:content_type => content_type, 
                               :composer_username => user.username, 
                               :publishing_state_id => ContentManagerSystem::PublishingState::INITIAL.id,
                               :publishing_workflow_id => content_type.publishing_workflow_id})

              locals = render_content_type_aspects(params[:content_type], blank_content)
              locals.store(:url_base, "/admin/cms/content/new/#{params[:content_type]}")
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
        app.get "/admin/cms/content/edit/:id/?*" do

          content = ContentManagerSystem::Content.get(params[:id])

          if content 
            if content.can_write?(user)            

              locals = render_content_type_aspects(content.content_type.id, content)
              locals.store(:url_base, "/admin/cms/content/edit/params[:id]")
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
        # Get the Gui with the publishing actions 
        #
        app.get "/render/publishing-actions/content/:id", :allowed_usergroups => ['staff', 'editor', 'webmaster'] do
 
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
        # Load the content status page
        #
        app.get "/render/status/content/:id" do
          
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
                                              :publishing_address => "/content/#{content.id}" , 
                                              :management_address => "/admin/cms/content/edit/#{content.id}"})
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

          call! env.merge("PATH_INFO" => "/render/status/content/#{params[:id]}")

        end

      end
    
    end #ContentManagement
  end #YSD
end #Sinatra