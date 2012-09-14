require 'uri'
module Sinatra
  module YSD
    module ContentTypeManagementRESTApi
   
      def self.registered(app)
         
        #
        # Retrieve content types (POST)
        #
        ["/accepted-content-types","/accepted-content-types/page/:page"].each do |path|
          app.post path do       
      
            data = ContentManagerSystem::ContentType.all
          
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
        app.get "/content-types" do
          data=ContentManagerSystem::ContentType.all
          
          # Prepare the result
          content_type :json
          data.to_json
        end
        
        #
        # Retrieve content types (POST)
        #
        ["/content-types","/content-types/page/:page"].each do |path|
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
        app.post "/content-type" do
        
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
        app.put "/content-type" do
                
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
        app.delete "/content-type" do
        
        end
      
        #
        # Get the entity/aspect configuration attributes
        #
        app.get "/content-type/:content_type/aspect/:aspect/config" do
        
          context = {:app => self}
    
          # TODO check that the content type exists and the aspect is set for it
              
          c_type = ::ContentManagerSystem::ContentType.get(params['content_type'])
          puts "content type : #{c_type.inspect}"
          c_type_aspect = c_type.aspect(params['aspect'])
          puts "content type aspect : #{c_type_aspect.inspect}"
          aspect = c_type_aspect.get_aspect(context)
          
          aspect_configuration = {}
          aspect.configuration_attributes.each do |aspect_config_attr|
             aspect_configuration.store(aspect_config_attr.id, 
                                        c_type_aspect.get_aspect_attribute_value(aspect_config_attr.id))
          end
          
          puts "aspect configuration : #{aspect_configuration.inspect}"
          
          status 200
          content_type :json
          aspect_configuration.to_json
        
        end
        
        #
        # Update the aspect/entity configuration attributes
        #
        app.put "/content-type/:content_type/aspect/:aspect/config" do
        
          context = {:app => self}
    
          # TODO check that the content type exists and the aspect is set for it
                 
          c_type = ::ContentManagerSystem::ContentType.get(params['content_type'])
          c_type_aspect = c_type.aspect(params['aspect'])
 
          request.body.rewind
          aspect_config_request = JSON.parse(URI.unescape(request.body.read)) 
         
          aspect_config_request.each do |variable, value|
            c_type_aspect.set_aspect_attribute_value(variable.to_sym, value)
          end

          status 200
          content_type :json
          aspect_config_request.to_json
        
        end      
      
      
      end
    
    end #ContentTypeManagement
  end #YSD
end #Sinatra