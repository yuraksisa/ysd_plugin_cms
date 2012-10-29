module Sinatra
  module YSD
    module MenuManagementRESTApi
       
      def self.registered(app)
               
        #
        # Retrieve all menus
        #
        app.get "/menus" do
          data = Site::Menu.all
          
          content_type :json
          data.to_json
        end
                
        #
        # Retrive menus
        #
        ["/menus","/menus/page/:page"].each do |path|
          app.post path do
          
            data=Site::Menu.all
            begin
              total=Site::Menu.count
            rescue
              total=Site::Menu.all.length
            end
            
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Retrieve a menu
        #
        app.get "/menu/:name" do
          
          puts "Getting menu"
          
          menu = Site::Menu.get(params['name'])
          
          puts "menu loaded : #{menu}"
          
          status 200
          content_type :json
          menu.to_json
        
        end
        
        #
        # Create a new menu
        #
        app.post "/menu" do
        
          puts "Creating menu"
          
          request.body.rewind
          menu_request = JSON.parse(URI.unescape(request.body.read))
          
          # Creates the new menu
          menu = Site::Menu.new(menu_request)
          menu.save
          
          puts "created menu : #{menu}"
          
          # Return          
          status 200
          content_type :json
          menu.to_json          
        
        end
        
        #
        # Updates a menu
        #
        app.put "/menu" do
        
          puts "Updating menu"
        
          request.body.rewind
          menu_request = JSON.parse(URI.unescape(request.body.read))
          
          # Updates the menu
          menu = Site::Menu.get(menu_request['name'])
          puts "updating menu : #{menu.to_json} ** #{menu_request}"
          menu.attributes=(menu_request)
          menu.save
          
          puts "updated menu : #{menu}"
                   
          # Return          
          status 200
          content_type :json
          menu.to_json
        
        
        end
        
        # Deletes a menu
        app.delete "/menu" do
        
        end
      
      end
    
    end #MenuManagementRESTApi
  end #YSD
end #Sinatra