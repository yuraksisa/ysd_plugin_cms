require 'uri'
module Sinatra
  module YSD
    #
    # Content Management REST API
    #
    module ContentManagementRESTApi
   
      def self.registered(app)
                            
        app.set :contents_page_size, 10                    
        
        #                    
        # Query contents
        #
        ["/contents","/contents/page/:page"].each do |path|
          
          app.post path do

            conditions = {}         
            
            if request.media_type == "application/x-www-form-urlencoded" # Just the text
              request.body.rewind
              search = JSON.parse(URI.unescape(request.body.read))
              if search.is_a?(Hash)
                search.each do |property, value| 
                  case property
                    when 'publishing_state_id'
                      conditions[:publishing_state_id] = value
                    when 'content_type_id'
                      conditions[:content_type] = {:id => value}  
                    when 'categories'
                      unless value.nil?
                        conditions[:categories] = value.map {|element| element.to_i}
                      end
                  end
                end
              end
            end

            page = params[:page].to_i || 1
            limit = settings.contents_page_size
            offset = (page-1) * settings.contents_page_size
            
            data  = ContentManagerSystem::Content.all(:conditions => conditions, :limit => limit, :offset => offset)
            total = ContentManagerSystem::Content.count(conditions)
          
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Get a content
        #
        app.get "/content/:id" do
        
          content = ContentManagerSystem::Content.get(params['id'])
          
          status 200
          content_type :json
          content.to_json
        
        end
        
        #
        # Create a new content
        #
        #  /content                  : Publish the content
        #  /content?op=save          : Save the content (create a draft)
        #  /content?op=creation-step : Just save
        #
        #
        app.post "/content" do
        
          options = extract_request_query_string
          
          content_request = body_as_json(ContentManagerSystem::Content)

          content = ContentManagerSystem::Content.new(content_request)

          if options.has_key?(:params) and options[:params].has_key?('op')
            case options[:params]['op'] 
              when 'save' # Draft
                content.save_publication
              when 'creation-step' # Creation step
                content.save
            end
          else
            content.publish_publication
          end

          # Return          
          status 200
          content_type :json
          content.to_json          
        
        end
        
        #
        # Updates a content
        #
        app.put "/content" do
          
          content_request = body_as_json(ContentManagerSystem::Content)
                              
          if content = ContentManagerSystem::Content.get(content_request.delete(:id))     
            content.attributes=(content_request)  
            content.save
          end
      
          content_type :json
          content.to_json        
        
        end
        
        #
        # Deletes a content
        #
        app.delete "/content" do
        
          content_request = body_as_json(ContentManagerSystem::Content)
          
          # Remove the content
          key = content_request.delete(:id)
          
          if content = ContentManagerSystem::Content.get(key)
            content.delete
          end
          
          content_type :json
          true.to_json
        
        
        end
      
        #
        # -------- Publishing ---------
        #
        

        #
        # Publish a content
        #
        app.post "/content/publish/:id" do

          if content = ContentManagerSystem::Content.get(params[:id])
            content.publish_publication
            content_type :json
            content.to_json
          else
            status 404 
          end
        end

        #
        # Publish multiple contents
        #
        app.post "/contents/publish" do

        end

        #
        # Confirm a content
        #
        app.post "/content/confirm/:id" do

          if content = ContentManagerSystem::Content.get(params[:id])
            content.confirm_publication
            content_type :json
            content.to_json
          else
            status 404
          end
        end

        #
        # Validate a content
        #
        app.post "/content/validate/:id" do

          if content = ContentManagerSystem::Content.get(params[:id])
            content.validate_publication
            content_type :json
            content.to_json
          else
            status 404
          end

        end

        #
        # Validate multiple contents
        #
        app.post "/contents/validate" do

        end

        #
        # Ban a content
        #
        app.post "/content/ban/:id" do

          if content = ContentManagerSystem::Content.get(params[:id])
            content.ban_publication
            content_type :json
            content.to_json
          else
            status 404
          end

        end
        
        #
        # Bans multiples contents
        #
        app.post "/contents/ban" do

        end

        #
        # Allow a content
        #
        app.post "/content/allow/:id" do

          if content = ContentManagerSystem::Content.get(params[:id])
            content.allow_publication
            content_type :json
            content.to_json
          else
            status 404
          end

        end

        #
        # Allow multiples contents
        #
        app.post "/contents/allow" do

        end

      end
    
    end #ContentManagement
  end #YSD
end #Sinatra