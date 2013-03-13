require 'uri'
module Sinatra
  module YSD
    #
    # Private REST API
    #
    # Sinatra extension to manage ContentManagerSystem::Block 
    #
    module BlockManagementRESTApi
   
      def self.registered(app)
        
        #
        # Retrieve all blocks
        #
        app.get "/blocks" do

          content_type :json
          ContentManagerSystem::Block.all.to_json        

        end
        
        # Retrive the blocks
        ["/blocks","/blocks/page/:page"].each do |path|
          app.post path do

            total = 0
            
            data=ContentManagerSystem::Block.all(:conditions => {:theme => Themes::ThemeManager.instance.selected_theme.name}, :order => [:name.asc])              

            begin
              total=ContentManagerSystem::Block.count(:theme => Themes::ThemeManager.instance.selected_theme.name)
            rescue
              total = data.length
            end
          
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        # Create a block
        app.post "/block" do
          
          body_request = body_as_json(ContentManagerSystem::Block)

          block = ContentManagerSystem::Block.create(body_request) 
             
          content_type :json
          block.to_json          
        
        end
        
        # Updates a block
        app.put "/block" do
          
          block_request = body_as_json(ContentManagerSystem::Block)      
          block_id = block_request.delete(:id)

          if block = ContentManagerSystem::Block.get(block_id)         
            block.attributes=(block_request)
            block.save
            puts "ERRORS : #{block.errors.inspect}"
          end

          content_type :json
          block.to_json
        
        end
        
        # Deletes a block
        app.delete "/block" do
        
        end
            
              
      end
    
    end #ViewManagement
  end #YSD
end #Sinatra