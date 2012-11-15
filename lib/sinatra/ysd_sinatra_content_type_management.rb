module Sinatra
  module YSD
    module ContentTypeManagement
   
      def self.registered(app)
            
        # Add the local folders to the views and translations     
        #app.settings.views = Array(app.settings.views).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'views')))
        #app.settings.translations = Array(app.settings.translations).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'i18n')))
        
        #
        # Content types management page
        #
        app.get "/mctypes/?*" do
          load_page(:content_type_management)
        end
        
        #
        # Entity aspects configuration : The configuration of a entity aspect
        #
        app.get "/mctype/:content_type/aspect/:aspect" do
          
          context = {:app => self}
                  
          content_type = ::ContentManagerSystem::ContentType.get(params['content_type'])
          aspect = content_type.get_aspect_definition(params['aspect'], context)
                  
          if content_type and aspect 

            locals = {}
            locals.store(:aspect, params['aspect'])
            locals.store(:model, params['content_type'])
            locals.store(:model_type, 'Content Type')
            locals.store(:update_url, "/ctype/#{content_type.id}/aspect/#{params['aspect']}/config")
            locals.store(:get_url,    "/ctype/#{content_type.id}/aspect/#{params['aspect']}/config")
            locals.store(:url_base,   "/ctype/#{content_type.id}/aspect/#{params['aspect']}")
            locals.store(:url_destination, "/mctypes/#{content_type.id}")
            locals.store(:description, "#{params['aspect']} - #{content_type.id}")
                    
            if aspect and aspect.respond_to?(:config)
              locals.store(:aspect_config_form, aspect.config(context))
            else
              locals.store(:aspect_config_form, '')
            end
      
            if aspect and aspect.respond_to?(:config_extension)
              locals.store(:aspect_config_form_extension, aspect.config_extension(context))
            else
              locals.store(:aspect_config_form_extension, '')
            end
          
            load_page(:model_aspect_configuration, :locals => locals)
          
          else
            
            status 404

          end

        end
        
        
              
      end
    
    end #ContentTypeManagement
  end #YSD
end #Sinatra