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
        app.get "/content-type-management" do
          load_page(:content_type_management)
        end
        
        #
        # Entity aspects configuration : The configuration of a entity aspect
        #
        app.get "/content-type/:content_type/aspect/:aspect" do
          
          context = {:app => self}
    
          # TODO check that the content type exists and the aspect is set for the content type
              
          content_type = ::ContentManagerSystem::ContentType.get(params['content_type'])
          aspect = (content_type.get_aspects(context).select { |aspect| aspect.id == params['aspect'].to_sym  }).first
                  
          locals = {}
          locals.store(:aspect, params['aspect'])
          locals.store(:update_url, "/content-type/#{content_type.id}/aspect/#{aspect.id}/config")
          locals.store(:get_url,    "/content-type/#{content_type.id}/aspect/#{aspect.id}/config")
          locals.store(:url_base,   "/content-type/#{content_type.id}/aspect/#{aspect.id}")
          locals.store(:description, "#{aspect.id} - #{content_type.id}")
                    
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
          
          load_page(:entity_aspect_configuration, :locals => locals)
          
        end
        
        
              
      end
    
    end #ContentTypeManagement
  end #YSD
end #Sinatra