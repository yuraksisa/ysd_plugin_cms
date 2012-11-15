module Sinatra
  module YSD
    module MenuItemManagementRESTApi
       
      def self.registered(app)
                    
        #
        # Retrieve the menu_items which belongs to a menu
        #
        app.get "/menu-items/:menu_name" do
          
          data=Site::MenuItem.all(:menu => {:name => params['menu_name']}, :order => [:parent_id.desc,:weight.desc])
          
          content_type :json
          data.to_json
        
        end
        
        #
        # Retrive the menu item parent candidadates
        #
        ["/menu-items-parent-candidate/:menu_name","/menu-items-parent-candidate/:menu_name/:menu_item_id"].each do |path|
        
          app.get path do
            data=Site::MenuItem.all(:menu => {:name => params['menu_name']}, :order => [:parent_id.desc,:weight.desc])
          
            content_type :json
            data.to_json          
          end
        
        end
        
        #
        # Retrive menu items
        #
        ["/menu-items/:menu_name","/menu-items/:menu_name/page/:page"].each do |path|
          app.post path do
          
            data=Site::MenuItem.all(:menu => {:name => params['menu_name']}, :order => [:parent_id.desc,:weight.desc])
            
            begin
              total=Site::MenuItem.count(:menu => {:name => params['menu_name']})
            rescue
              total=Site::MenuItem.all(:menu => {:name => params['menu_name']}).length
            end
            
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Retrieve a menu item
        #
        app.get "/menu-item/:id" do
          
          menu_item = Site::MenuItem.get(params['id'])
          
          status 200
          content_type :json
          menu_item.to_json
        
        end
        
        #
        # Create a new term
        #
        app.post "/menu-item" do
        
          request.body.rewind
          menu_item_request = JSON.parse(URI.unescape(request.body.read))
          
          # Creates the new content
          menu_item = Site::MenuItem.new(menu_item_request)
          menu_item.save
          
          # Return          
          status 200
          content_type :json
          menu_item.to_json          
        
        end
        
        #
        # Updates a term
        #
        app.put "/menu-item" do
        
          request.body.rewind
          menu_item_request = JSON.parse(URI.unescape(request.body.read))
          
          # Updates the menu item
          menu_item = Site::MenuItem.get(menu_item_request['id'])
          menu_item.attributes=(menu_item_request)
          menu_item.save
                   
          # Return          
          status 200
          content_type :json
          menu_item.to_json
        
        
        end
        
        # Deletes a content
        app.delete "/menu-item" do
        
          request.body.rewind
          menu_item_request = JSON.parse(URI.unescape(request.body.read))

          # Remove the storage
          if menu_item = Site::MenuItem.get(menu_item_request['id'])
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