require 'ysd_md_menu_item'
module Sinatra
  module YSD
    #
    # Menu item REST API
    # 
    module MenuItemManagementRESTApi
       
      def self.registered(app)
                    
        #
        # Retrieve the menu_items which belongs to a menu
        #
        app.get "/api/menu-items/:menu_name", :allowed_usergroups => ['staff','webmaster'] do
          
          data=::Site::MenuItem.all(:menu => {:name => params['menu_name']}, :order => [:parent_id.desc,:weight.desc])
          
          content_type :json
          data.to_json
        
        end
        
        #
        # Retrive the menu item parent candidadates
        #
        ["/api/menu-items-parent-candidate/:menu_name",
         "/api/menu-items-parent-candidate/:menu_name/:menu_item_id"].each do |path|
        
          app.get path, :allowed_usergroups => ['staff','webmaster'] do
            data=::Site::MenuItem.all(:menu => {:name => params['menu_name']}, :order => [:parent_id.desc,:weight.desc])
          
            content_type :json
            data.to_json          
          end
        
        end
        
        #
        # Retrive menu items
        #
        ["/api/menu-items/:menu_name","/api/menu-items/:menu_name/page/:page"].each do |path|
          app.post path, :allowed_usergroups => ['staff','webmaster'] do
          
            data=::Site::MenuItem.all(:menu => {:name => params['menu_name']}, :order => [:parent_id.desc,:weight.desc])
            
            begin
              total=::Site::MenuItem.count(:menu => {:name => params['menu_name']})
            rescue
              total=::Site::MenuItem.all(:menu => {:name => params['menu_name']}).length
            end
            
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Retrieve a menu item
        #
        app.get "/api/menu-item/:id", :allowed_usergroups => ['staff','webmaster'] do
          
          menu_item = ::Site::MenuItem.get(params['id'])
          
          status 200
          content_type :json
          menu_item.to_json
        
        end
        
        #
        # Create a new term
        #
        app.post "/api/menu-item", :allowed_usergroups => ['staff','webmaster'] do
        
          request.body.rewind
          menu_item_request = JSON.parse(URI.unescape(request.body.read))
          
          # Creates the new content
          menu_item = ::Site::MenuItem.new(menu_item_request)
          p "errors: #{menu_item.errors.full_messages.inspect} errors: #{menu_item.errors.inspect} valid: #{menu_item.valid?} value: #{menu_item.inspect}"
          menu_item.save
          
          # Return          
          status 200
          content_type :json
          menu_item.to_json          
        
        end
        
        #
        # Updates a term
        #
        app.put "/api/menu-item", :allowed_usergroups => ['staff','webmaster'] do
        
          request.body.rewind
          menu_item_request = JSON.parse(URI.unescape(request.body.read))
          
          # Updates the menu item
          menu_item = ::Site::MenuItem.get(menu_item_request['id'])
          menu_item.attributes=(menu_item_request)
          menu_item.save
                   
          # Return          
          status 200
          content_type :json
          menu_item.to_json
        
        
        end
        
        # Deletes a content
        app.delete "/api/menu-item", :allowed_usergroups => ['staff','webmaster'] do
        
          request.body.rewind
          menu_item_request = JSON.parse(URI.unescape(request.body.read))

          # Remove the storage
          if menu_item = ::Site::MenuItem.get(menu_item_request['id'])
            menu_item.destroy
          end
          
          # Return
          status 200
          content_type :json
          true.to_json
        
        end
      
      end
    
    end #MenuItemManagementRESTApi
  end #YSD
end #Sinatra