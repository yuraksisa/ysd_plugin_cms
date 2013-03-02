require 'uri'
module Sinatra
  module YSD
    #
    # Private REST API
    #
    # Sinatra extension to manage ContentManagerSystem::ContentType
    #
    module ContentTypeManagementRESTApi
   
      def self.registered(app)

        #
        # Retrieve the content types the user can create (GET)
        #        
        app.get "/ctypesuser/?" do
          
          data = ContentManagerSystem::ContentType.all(:content_type_user_groups => { :usergroup => user.usergroups })
          
          content_type :json
          data.to_json

        end

        #
        # Retrieve the content types the user can create (POST)
        #
        ["/ctypesuser/?","/ctypesuser/page/:page"].each do |path|
          app.post path do       
      
            data = ContentManagerSystem::ContentType.all(:content_type_user_groups => { :usergroup => user.usergroups })
          
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
          content_type :json
          ContentManagerSystem::ContentType.all.to_json
        end
      
        #
        # Retrieve a content type (GET)
        #
        app.get "/ctype/:id" do
        
          the_content_type = ContentManagerSystem::ContentType.get(params[:id])
          
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
          
          content_type_request = body_as_json(ContentManagerSystem::ContentType)

          m_content_type = ContentManagerSystem::ContentType.create(content_type_request) 
          
          content_type :json
          m_content_type.to_json          
        
        end
        
        #
        # Updates a content type
        #
        app.put "/ctype" do
          
          content_type_request = body_as_json(ContentManagerSystem::ContentType)
          content_type_id = content_type_request.delete(:id)

          if m_content_type = ContentManagerSystem::ContentType.get(content_type_id)
            m_content_type.attributes=(content_type_request)
            m_content_type.save
          end

          content_type :json
          m_content_type.to_json
        
        end
        
        #
        # Deletes a content type
        #
        app.delete "/ctype" do
           
          content_type_request = body_as_json(ContentManagerSystem::ContentType)
          content_type_id = content_type_request.delete(:id)

          if m_content_type = ContentManagerSystem::ContentType.get(content_type_id)
            m_content_type.destroy
          end

          status 200
          content_type :json
          true.to_json

        end
      
        #
        # Get the content type aspect configuration attributes
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
        # Update the content type aspect configuration attributes
        #
        app.put "/ctype/:content_type/aspect/:aspect/config" do
                             
          c_type = ::ContentManagerSystem::ContentType.get(params[:content_type])
          c_type_aspect = c_type.aspect(params[:aspect])
 
          if c_type and c_type_aspect
            request.body.rewind
            aspect_configuration_request = JSON.parse(URI.unescape(request.body.read))
            
            if aspect_configuration_attributes = aspect_configuration_request['aspect_attributes']
              ContentManagerSystem::ContentTypeAspect.transaction do |transaction|
                c_type_aspect.aspect_attributes=aspect_configuration_attributes
                transaction.commit
              end
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