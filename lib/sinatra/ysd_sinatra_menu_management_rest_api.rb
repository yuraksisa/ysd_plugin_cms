require 'ysd_md_menu'
module Sinatra
  module YSD
    #
    # Menu management REST API
    #
    module MenuManagementRESTApi
       
      def self.registered(app)
               
        #
        # Retrieve all menus
        #
        app.get "/api/menus", :allowed_usergroups => ['staff'] do
          data = ::Site::Menu.all
          
          content_type :json
          data.to_json
        end
                
        #
        # Retrive menus
        #
        ["/api/menus","/api/menus/page/:page"].each do |path|
          app.post path, :allowed_usergroups => ['staff'] do
          
            data=::Site::Menu.all
            begin
              total=::Site::Menu.count
            rescue
              total=::Site::Menu.all.length
            end
            
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Retrieve a menu
        #
        app.get "/api/menu/:name", :allowed_usergroups => ['staff'] do

          menu = ::Site::Menu.get(params['name'])
          
          status 200
          content_type :json
          menu.to_json
        
        end
        
        #
        # Create a new menu
        #
        app.post "/api/menu", :allowed_usergroups => ['staff'] do
        
          request.body.rewind
          menu_request = JSON.parse(URI.unescape(request.body.read))
          
          # Creates the new menu
          menu = ::Site::Menu.new(menu_request)
          menu.save
                   
          # Return          
          status 200
          content_type :json
          menu.to_json          
        
        end
        
        #
        # Updates a menu
        #
        app.put "/api/menu", :allowed_usergroups => ['staff'] do
        
          request.body.rewind
          menu_request = JSON.parse(URI.unescape(request.body.read))
          
          # Updates the menu
          menu = ::Site::Menu.get(menu_request['name'])
          menu.attributes=(menu_request)
          menu.save
                             
          # Return          
          status 200
          content_type :json
          menu.to_json
        
        end
        
        # Deletes a menu
        app.delete "/api/menu", :allowed_usergroups => ['staff'] do
        
        end
      
      end
    
    end #MenuManagementRESTApi
  end #YSD
end #Sinatra