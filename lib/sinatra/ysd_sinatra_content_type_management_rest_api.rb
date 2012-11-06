require 'uri'
module Sinatra
  module YSD
    module ContentTypeManagementRESTApi
   
      def self.registered(app)

        #
        # Retrieve the content types the user can create (GET)
        #        
        app.get "/ctypesuser/?" do

          data = ContentManagerSystem::ContentType.all('usergroups.usergroup.group' => user.usergroups)
          
          content_type :json
          data.to_json

        end

        #
        # Retrieve the content types the user can create (POST)
        #
        ["/ctypesuser/?","/ctypesuser/page/:page"].each do |path|
          app.post path do       
      
            data = ContentManagerSystem::ContentType.all('usergroups.usergroup.group' => user.usergroups)
          
            begin # Count does not work for all adapters
              total=ContentManagerSystem::ContentType.count
            rescue
              total=ContentManagerSystem::ContentType.all.length
            end          
          
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
            
          end
        end
                    
        #
        # Retrive all content types (GET)
        #
        app.get "/ctypes" do
          data=ContentManagerSystem::ContentType.all
          
          # Prepare the result
          content_type :json
          data.to_json
        end
      
        #
        # Retrieve a content type (GET)
        #
        app.get "/ctype/:id" do
        
          the_content_type = ContentManagerSystem::ContentType.get(params['id'])
          
          status 200
          content_type :json
          the_content_type.to_json
        
        end

        #
        # Retrieve content types (POST)
        #
        ["/ctypes","/ctypes/page/:page"].each do |path|
          app.post path do
          
            data=ContentManagerSystem::ContentType.all
            
            begin # Count does not work for all adapters
              total=ContentManagerSystem::ContentType.count
            rescue
              total=ContentManagerSystem::ContentType.all.length
            end
            
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Create a new content type
        #
        app.post "/ctype" do
        
          request.body.rewind
          content_type_request = JSON.parse(URI.unescape(request.body.read))
          
          # Creates the new content
          the_content_type = ContentManagerSystem::ContentType.create(content_type_request) 
          
          # Return          
          status 200
          content_type :json
          the_content_type.to_json          
        
        end
        
        #
        # Updates a content type
        #
        app.put "/ctype" do
                
          request.body.rewind
          content_type_request = JSON.parse(URI.unescape(request.body.read))
                    
          # Updates the content type          
          the_content_type = ContentManagerSystem::ContentType.get(content_type_request['id'])
          the_content_type.attributes=(content_type_request)
          the_content_type.save
                             
          # Return          
          status 200
          content_type :json
          the_content_type.to_json
        
        
        end
        
        #
        # Deletes a content type
        #
        app.delete "/ctype" do
        
          request.body.rewind
          content_type_request = JSON.parse(URI.unescape(request.body.read))

          # Delete the content type
          the_content_type = ContentManagerSystem::ContentType.get(content_type_request['id'])
          the_content_type.destroy

          status 200
          content_type :json
          true.to_json

        end
      
        #
        # Get the entity/aspect configuration attributes
        #
        app.get "/ctype/:content_type/aspect/:aspect/config" do
          
          c_type = ::ContentManagerSystem::ContentType.get(params['content_type'])
          c_type_aspect = c_type.aspect(params['aspect'])

          if c_type and c_type_aspect                    
            status 200
            content_type :json
            c_type_aspect.to_json
          else
            status 404
          end

        end
        
        #
        # Update the aspect/entity configuration attributes
        #
        app.put "/ctype/:content_type/aspect/:aspect/config" do
                             
          c_type = ::ContentManagerSystem::ContentType.get(params['content_type'])
          c_type_aspect = c_type.aspect(params['aspect'])
 
          if c_type and c_type_aspect
            request.body.rewind
            aspect_configuration_request = JSON.parse(URI.unescape(request.body.read))
            aspect_configuration_attributes = aspect_configuration_request.delete('aspect_attributes')
            
            ContentManagerSystem::ContentTypeAspect.transaction do |transaction|
              c_type_aspect.attributes= aspect_configuration_request
              c_type_aspect.save
              c_type_aspect.aspect_attributes=aspect_configuration_attributes
              transaction.commit
            end

            status 200
            content_type :json
            c_type_aspect.to_json
          else
            status 404
          end

        end      
      
      
      end
    
    end #ContentTypeManagement
  end #YSD
end #Sinatra