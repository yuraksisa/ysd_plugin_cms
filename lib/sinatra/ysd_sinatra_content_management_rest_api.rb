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
        # Retrieve the content render templates
        #
        app.get "/api/displays/content" do 

          resources = find_resources(/^render-content-.+\.erb/).map do |item|
            {:id => (value=item[15..-5]), :description => value}
          end

          content_type :json
          resources.to_json

        end

        #                    
        # Query contents
        #
        ["/api/contents","/api/contents/page/:page"].each do |path|
          
          app.post path do

            conditions = {}         
            if request.media_type == "application/json" # Just the text
              request.body.rewind
              search_params = URI.unescape(request.body.read)
              unless search_params.empty?
                search = JSON.parse(search_params)
                if search.is_a?(Hash)
                  search.each do |property, value| 
                    case property
                      when 'publishing_state_id'
                        conditions[:publishing_state_id] = value unless value.empty?
                      when 'content_type_id'
                        conditions[:content_type] = {:id => value} unless value.empty?
                      when 'categories'
                        unless value.nil?
                          conditions[:categories] = value.map {|element| element.to_i} unless value.empty?
                        end
                    end
                  end
                end
              end
            end

            page = params[:page].to_i || 1
            limit = settings.contents_page_size
            offset = (page-1) * settings.contents_page_size
            
            data  = ContentManagerSystem::Content.all(:conditions => conditions, :limit => limit, :offset => offset, :order => :content_name.asc)
            total = ContentManagerSystem::Content.count(conditions)
          
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Get a content
        #
        app.get "/api/content/:id" do
        
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
        app.post "/api/content", :allowed_usergroups => ['staff','editor','webmaster'] do
        
          options = extract_request_query_string
          
          content_request = body_as_json(ContentManagerSystem::Content)

          content_request.delete(:album_id) if content_request[:album_id].empty? 

          content = ContentManagerSystem::Content.new(content_request)

          p "content: #{content.valid?} -- errors: #{content.errors.full_messages.inspect}"

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
        app.put "/api/content", :allowed_usergroups => ['staff','editor','webmaster'] do
          
          content_request = body_as_json(ContentManagerSystem::Content)
          content_request.delete(:album_id) if content_request[:album_id].empty? 

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
        app.delete "/api/content", :allowed_usergroups => ['staff','editor','webmaster'] do
        
          content_request = body_as_json(ContentManagerSystem::Content)
          
          # Remove the content
          key = content_request.delete(:id)
          
          if content = ContentManagerSystem::Content.get(key)
            content.destroy
          end
          
          content_type :json
          true.to_json
        
        
        end
        

        #
        # Publish a content
        #
        app.post "/api/content/publish/:id", :allowed_usergroups => ['staff','editor','webmaster'] do

          if content = ContentManagerSystem::Content.get(params[:id])
            content.publish_publication
            content_type :json
            content.to_json
          else
            status 404 
          end
        end

        #
        # Confirm a content
        #
        app.post "/api/content/confirm/:id", :allowed_usergroups => ['staff','editor','webmaster'] do

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
        app.post "/api/content/validate/:id", :allowed_usergroups => ['staff','editor','webmaster'] do

          if content = ContentManagerSystem::Content.get(params[:id])
            content.validate_publication
            content_type :json
            content.to_json
          else
            status 404
          end

        end

        #
        # Ban a content
        #
        app.post "/api/content/ban/:id", :allowed_usergroups => ['staff','editor','webmaster'] do

          if content = ContentManagerSystem::Content.get(params[:id])
            content.ban_publication
            content_type :json
            content.to_json
          else
            status 404
          end

        end
        
        #
        # Allow a content
        #
        app.post "/api/content/allow/:id", :allowed_usergroups => ['staff','editor','webmaster'] do

          if content = ContentManagerSystem::Content.get(params[:id])
            content.allow_publication
            content_type :json
            content.to_json
          else
            status 404
          end

        end

      end
    
    end #ContentManagement
  end #YSD
end #Sinatra