module Sinatra
  module YSD
    module MenuManagement
       
      def self.registered(app)

        # Add the local folders to the views and translations     
        app.settings.views = Array(app.settings.views).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'views')))
        app.settings.translations = Array(app.settings.translations).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'i18n')))       
                    
        #
        # Taxonomies management page
        #        
        app.get "/menu-management/?*" do
          puts "Llego a /menu-management"
          load_page 'menu_management'.to_sym
        end
        
      
      end
    
    end #MenuManagement
  end #YSD
end #Sinatra