module Sinatra
  module YitoExtension
    module RedirectManagementRESTApi

      def self.registered(app)

        #                    
        # Query redirects
        #
        ["/api/cms/redirects","/api/cms/redirects/page/:page"].each do |path|
          
          app.post path, :allowed_usergroups => ['editor', 'staff','webmaster'] do

            page = params[:page].to_i || 1
            limit = 20
            offset = (page-1) * 20

            conditions = {}         
            
            if request.media_type == "application/x-www-form-urlencoded" # Just the text
              search_text = if params[:search]
                              params[:search]
                            else
                              request.body.rewind
                              request.body.read
                            end
              conditions = Conditions::Comparison.new(:id, '$eq', search_text.to_i)

              total = conditions.build_datamapper(ContentManagerSystem::Redirect).all.count 
              data = conditions.build_datamapper(ContentManagerSystem::Redirect).all(:limit => limit, :offset => offset) 
            else
              data  = ContentManagerSystem::Redirect.all(:limit => limit, :offset => offset)
              total = ContentManagerSystem::Redirect.count
                                          
            end
            
          
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Get redirects
        #
        app.get "/api/cms/redirects", :allowed_usergroups => ['editor', 'staff','webmaster'] do

          data = ContentManagerSystem::Redirect.all

          status 200
          content_type :json
          data.to_json

        end

        #
        # Get redirect
        #
        app.get "/api/cms/redirect/:id", :allowed_usergroups => ['editor', 'staff','webmaster'] do
        
          data = ContentManagerSystem::Redirect.get(params[:id].to_i)
          
          status 200
          content_type :json
          data.to_json
        
        end
        
        #
        # Create redirect
        #
        app.post "/api/cms/redirect/?", :allowed_usergroups => ['editor', 'staff','webmaster'] do
        
          data_request = body_as_json(ContentManagerSystem::Redirect)
          data = ContentManagerSystem::Redirect.create(data_request)
         
          status 200
          content_type :json
          data.to_json          
        
        end
        
        #
        # Updates redirect
        #
        app.put "/api/cms/redirect/?", :allowed_usergroups => ['editor', 'staff','webmaster'] do
          
          data_request = body_as_json(ContentManagerSystem::Redirect)
                              
          p "data_request:#{data_request.inspect}"                    
          if data = ContentManagerSystem::Redirect.get(data_request.delete(:id).to_i)     
            data.attributes=data_request  
            p "data:#{data.valid?}"
            data.save
          end
      
          content_type :json
          data.to_json        
        
        end
        
        #
        # Deletes redirect 
        #
        app.delete "/api/cms/redirect/?", :allowed_usergroups => ['editor', 'staff','webmaster'] do
        
          data_request = body_as_json(ContentManagerSystem::Redirect)
          
          key = data_request.delete(:id).to_i
          
          if data = ContentManagerSystem::Redirect.get(key)
            data.destroy
          end
          
          content_type :json
          true.to_json
        
        end

      end
    end
  end
end