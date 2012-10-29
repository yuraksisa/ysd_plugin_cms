module Sinatra
  module YSD
    module MenuItemManagement
       
      def self.registered(app)
                       
        #
        # Menu item management page
        #        
        app.get "/menu-item-management/:menu_name/?*" do
          load_page 'menu_item_management'.to_sym
          # TODO check that the menu name exists
        end
              
      end
    
    end #MenuItemManagement
  end #YSD
end #Sinatra