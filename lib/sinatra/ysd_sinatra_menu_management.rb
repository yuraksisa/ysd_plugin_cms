module Sinatra
  module YSD
    module MenuManagement
       
      def self.registered(app)

        #
        # New menu item
        #
        app.get "/admin/cms/menu/:menu_name", :allowed_usergroups => ['staff','webmaster']  do

          @menu = ::Site::Menu.get(params[:menu_name])
          @translations = settings.multilanguage_site
          load_page(:cms_menu, layout: false)

        end

        #
        # Taxonomies management page
        #        
        app.get "/admin/cms/menu-management/?*", :allowed_usergroups => ['staff','webmaster'] do
          load_em_page :menu_management, nil, false
        end
              
      end
    
    end #MenuManagement
  end #YSD
end #Sinatra