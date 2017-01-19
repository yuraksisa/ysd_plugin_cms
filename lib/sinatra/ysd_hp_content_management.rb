module Sinatra
 module YSD
  #
  # Helper function to manage contents
  #
  module ContentManagementHelper

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
            publishing_actions.store('PEND_CONF', {:action => 'REDIRECT_TO_STATUS' , :url_prefix => '/render/status/content'})
            publishing_actions.store('PUBLISHED', {:action => 'REDIRECT_TO_PUBLICATION', :url_prefix => '/content/'})

            return publishing_actions
          end

          #
          # Helper to create the new content buttons
          #
          def build_creation_buttons(available_actions)

            creation_buttons = []

            if available_actions.any? { |action| action == ContentManagerSystem::PublishingAction::SAVE}
              creation_buttons << {:id => 'save_content', :text => 'Save', :url => '/api/content?op=save', :class => 'publishing-button-save'} 
            end
            
            if available_actions.any? { |action| action == ContentManagerSystem::PublishingAction::PUBLISH }
              creation_buttons << {:id => 'publish_content', :text => 'Publish', :url  => '/api/content', :class => 'publishing-button-publish'} 
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
              aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::ScriptStyle.new, {:weight => 103, :in_group => true, :show_on_new => false})
              aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::ContentOther.new, {:weight => 104, :in_group => true, :show_on_new => false})
              aspects_render = UI::EntityManagementAspectRender.new(context, aspects) 
              result = aspects_render.render(content_type)

            end            

            return result
          
          end

  end
 end
end