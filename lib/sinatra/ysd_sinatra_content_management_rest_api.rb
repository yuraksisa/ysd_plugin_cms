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

            query_conditions = nil          
            
            if request.media_type == "application/x-www-form-urlencoded" # Just the text
              request.body.rewind
              search = JSON.parse(URI.unescape(request.body.read))
              if search.is_a?(Hash)
                conditions = []
                search.each do |property, value| 
                  case property
                    when 'publishing_state'
                      conditions << Conditions::Comparison.new(property.to_sym, '$eq', value)
                    when 'type'
                      conditions << Conditions::Comparison.new(property.to_sym, '$eq', value)
                    when 'categories'
                      unless value.nil?
                        conditions << Conditions::Comparison.new(property.to_sym, '$in', value.map {|element| element.to_i}) 
                      end
                  end
                end
                if conditions.length > 1
                  query_conditions = Conditions::JoinComparison.new('$and', conditions)
                else
                  if conditions.length == 1
                    query_conditions = conditions.first
                  end 
                end            
              else
                # None in this moment
              end
            end

            page = params[:page].to_i || 1
            limit = settings.contents_page_size
            offset = (page-1) * settings.contents_page_size
            
            query_opts =  {:limit => limit, :offset => offset}
            unless query_conditions.nil?
              query_opts.store(:conditions, query_conditions)
            end

            data, total = ContentManagerSystem::Content.find_all(query_opts)
          
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
        #  /content?op=creation-step : Just save ()
        #
        #
        app.post "/content" do
        
          options = extract_request_query_string
          
          request.body.rewind
          content_request = JSON.parse(URI.unescape(request.body.read))
          content = ContentManagerSystem::Content.new(nil, content_request)

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
                
          request.body.rewind
          content_request = JSON.parse(URI.unescape(request.body.read))
          
          # Updates an existing content
          key = content_request.delete('key')
          
          content = ContentManagerSystem::Content.get(key)
          content.attributes=(content_request)
             
          content.update
          
          # Return          
          content_type :json
          content.to_json
        
        
        end
        
        #
        # Deletes a content
        #
        app.delete "/content" do
        
          request.body.rewind
          content_request = JSON.parse(URI.unescape(request.body.read))
          
          # Remove the content
          key = content_request.delete('key')
          
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

          content = ContentManagerSystem::Content.get(params[:id])
          content.publish_publication
          
          content_type :json
          content.to_json

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

          content = ContentManagerSystem::Content.get(params[:id])
          content.confirm_publication
          
          content_type :json
          content.to_json

        end

        #
        # Validate a content
        #
        app.post "/content/publish/:id" do

          content = ContentManagerSystem::Content.get(params[:id])
          content.validate_publication
          
          content_type :json
          content.to_json

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

          content = ContentManagerSystem::Content.get(params[:id])
          content.ban_publication
          
          content_type :json
          content.to_json

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

          content = ContentManagerSystem::Content.get(params[:id])
          content.allow_publication
          
          content_type :json
          content.to_json

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