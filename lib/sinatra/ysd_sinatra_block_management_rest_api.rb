require 'uri'
module Sinatra
  module YSD
    module BlockManagementRESTApi
   
      def self.registered(app)

        app.helpers do
          def prepare_block(block)
             block_usergroups = block.block_usergroups.map do |bug| 
               {:usergroup => {:group => bug.usergroup.group}, :block => {:id => bug.block.id} } 
             end                              
             block.attributes.merge({:block_usergroups => block_usergroups})       
          end
        end   

        
        #
        # Retrieve all blocks
        #
        app.get "/blocks" do

            data = ContentManagerSystem::Block.all

            content_type :json
            data.to_json        

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
          
            data = data.map do |block| 
              prepare_block(block)
            end
          
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        # Create a block
        app.post "/block" do

          puts "Creating block"
           
          request.body.rewind
          block_request = JSON.parse(URI.unescape(request.body.read))
          
          # Creates the new content
          block = ContentManagerSystem::Block.create(view_request) 
          
          puts "created block : #{block}"
                    
          # Return          
          status 200
          content_type :json
          block.to_json          
        
        end
        
        # Updates a block
        app.put "/block" do
        
          puts "Updating block"
        
          request.body.rewind
          block_request = JSON.parse(URI.unescape(request.body.read))
          
          block_request_usergroups = block_request['block_usergroups']
          block_request.delete('block_usergroups')          
          
          # Updates the existing block
          block = ContentManagerSystem::Block.get(block_request['id'])         
          block.attributes=(block_request)
          block.assign_usergroups(block_request_usergroups.map { |brug| brug['usergroup']['group'] })
          block.save
          
          # Return          
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