require 'uri'
module Sinatra
  module YSD
    module ContentManagementRESTApi
   
      def self.registered(app)
                            
        app.set :contents_page_size, 10                    
                            
        # Retrive the contents
        ["/contents","/contents/page/:page"].each do |path|
          
          app.post path do
          
            page = params[:page].to_i || 1
            limit = settings.contents_page_size
            offset = (page-1) * settings.contents_page_size
            
            data, total = ContentManagerSystem::Content.find_all({:limit => limit, :offset => offset})
          
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        app.get "/content/:id" do
        
          content = ContentManagerSystem::Content.get(params['id'])
          
          status 200
          content_type :json
          content.to_json
        
        end
        
        # Create a new content
        app.post "/content" do
        
          puts "Creating content"
          
          request.body.rewind
          content_request = JSON.parse(URI.unescape(request.body.read))
          
          content = ContentManagerSystem::Content.create(content_request)
          
          # Return          
          status 200
          content_type :json
          content.to_json          
        
        end
        
        # Updates a content
        app.put "/content" do
        
          puts "Updating content"
        
          request.body.rewind
          content_request = JSON.parse(URI.unescape(request.body.read))
          
          # Updates an existing content
          key = content_request.delete('key')
          
          content = ContentManagerSystem::Content.get(key)
          content.attributes=(content_request)
          
          puts "updating content : #{content}"
          
          content.update
          
          # Return          
          content_type :json
          content.to_json
        
        
        end
        
        # Deletes a content
        app.delete "/content" do
        
        end
      
      end
    
    end #ContentManagement
  end #YSD
end #Sinatra