require 'ui/ysd_ui_entity_management_aspect_render' 
require 'guiblocks/ysd_guiblock_aspects'
require 'ui/ysd_ui_guiblock_entity_aspect_adapter'

module Sinatra
  module YSD
    #
    # Content type management
    #
    module ContentTypeManagement
   
      def self.registered(app)
                   
        #
        # Content types management page
        #
        app.get "/mctypes/?*", :allowed_usergroups => ['staff']  do
          
          context = {:app => self}

          aspects = []
          aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::Aspects.new('/mctype', 'content'), {:render_in_group => true})
          
          aspects_render=UI::EntityManagementAspectRender.new(context, aspects) 
          locals = aspects_render.render(nil)

          load_em_page(:content_type_management, :contenttype, false, :locals => locals)
        
        end
        
        #
        # Configuration of a content type aspect (to set up the aspect attributes)
        #
        app.get "/mctype/:content_type/aspect/:aspect", :allowed_usergroups => ['staff']  do
          
          context = {:app => self}
                  
          content_type = ::ContentManagerSystem::ContentType.get(params['content_type'])

          aspect = content_type.aspect(params[:aspect]).get_aspect(context)
                  
          if content_type and aspect 

            locals = {}
            locals.store(:aspect, params['aspect'])
            locals.store(:model, params['content_type'])
            locals.store(:model_type, 'Content Type')
            locals.store(:update_url, "/ctype/#{content_type.id}/aspect/#{params[:aspect]}/config")
            locals.store(:get_url,    "/ctype/#{content_type.id}/aspect/#{params[:aspect]}/config")
            locals.store(:url_base,   "/ctype/#{content_type.id}/aspect/#{params[:aspect]}")
            locals.store(:url_destination, "/mctypes/#{content_type.id}")
            locals.store(:description, "#{params[:aspect]} - #{content_type.id}")
                    
            if aspect.gui_block.respond_to?(:config)
              locals.store(:aspect_config_form, aspect.gui_block.config(context, content_type))
            else
              locals.store(:aspect_config_form, '')
            end
      
            if aspect.gui_block.respond_to?(:config_extension)
              locals.store(:aspect_config_form_extension, aspect.gui_block.config_extension(context, content_type))
            else
              locals.store(:aspect_config_form_extension, '')
            end
          
            load_em_page(:model_aspect_configuration, nil, false, :locals => locals)
          
          else
            
            status 404

          end

        end
        
        
              
      end
    
    end #ContentTypeManagement
  end #YSD
end #Sinatra