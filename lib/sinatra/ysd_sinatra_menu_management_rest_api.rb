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
        app.get "/api/menus", :allowed_usergroups => ['staff','webmaster'] do
          data = ::Site::Menu.all
          
          content_type :json
          data.to_json
        end
                
        #
        # Retrive menus
        #
        ["/api/menus","/api/menus/page/:page"].each do |path|
          app.post path, :allowed_usergroups => ['staff','webmaster'] do
          
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
        app.get "/api/menu/:name", :allowed_usergroups => ['staff','webmaster'] do

          menu = ::Site::Menu.get(params['name'])
          
          status 200
          content_type :json
          menu.to_json
        
        end
        
        #
        # Create a new menu
        #
        app.post "/api/menu", :allowed_usergroups => ['staff','webmaster'] do
        
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
        # Order menu items
        #
        app.post '/api/menu/:id/order', allowed_usergroups: ['staff', 'webmaster'] do
          
          if menu = ::Site::Menu.get(params[:id])
            status 200
            content_type :json
            params['menu-item'].each_index do |idx|
              if menu_item=::Site::MenuItem.get(params['menu-item'][idx])
                menu_item.update(weight: idx)
              end  
            end  
            menu.reload
            menu.to_json
          else
            status 404
          end  

        end  

        #
        # Order submenu items
        #
        app.post '/api/submenu/:id/order', allowed_usergroups: ['staff', 'webmaster'] do
          
          if menu_item = ::Site::MenuItem.get(params[:id])
            status 200
            content_type :json
            params['menu-item'].each_index do |idx|
              if menu_item=::Site::MenuItem.get(params['menu-item'][idx])
                menu_item.update(weight: idx)
              end  
            end  
            menu_item.reload
            menu_item.to_json
          else
            status 404
          end 

        end  

        #
        # Updates a menu
        #
        app.put "/api/menu", :allowed_usergroups => ['staff','webmaster'] do
        
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
        app.delete "/api/menu", :allowed_usergroups => ['staff','webmaster'] do
        
        end
      
      end
    
    end #MenuManagementRESTApi
  end #YSD
end #Sinatra