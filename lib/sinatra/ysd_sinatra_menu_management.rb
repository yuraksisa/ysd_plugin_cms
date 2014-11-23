module Sinatra
  module YSD
    module MenuManagement
       
      def self.registered(app)
                   
        #
        # Taxonomies management page
        #        
        app.get "/admin/cms/menu-management/?*", :allowed_usergroups => ['staff'] do
          load_page :menu_management
        end
              
      end
    
    end #MenuManagement
  end #YSD
end #Sinatra