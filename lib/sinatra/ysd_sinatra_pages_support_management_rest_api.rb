module Sinatra
  module YitoExtension
    module PagesSupportManagementRESTApi

      def self.registered(app)

        #                    
        # Query page support
        #
        ["/api/cms/pages-support","/api/cms/pages-support/page/:page"].each do |path|
          
          app.post path do

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

              total = conditions.build_datamapper(ContentManagerSystem::PageSupport).all.count 
              data = conditions.build_datamapper(ContentManagerSystem::PageSupport).all(:limit => limit, :offset => offset) 
            else
              data  = ContentManagerSystem::PageSupport.all(:limit => limit, :offset => offset)
              total = ContentManagerSystem::PageSupport.count
                                          
            end
            
          
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Get page support
        #
        app.get "/api/cms/pages-support" do

          data = ContentManagerSystem::PageSupport.all

          status 200
          content_type :json
          data.to_json

        end

        #
        # Get page support
        #
        app.get "/api/cms/page-support/:id" do
        
          data = ContentManagerSystem::PageSupport.get(params[:id].to_i)
          
          status 200
          content_type :json
          data.to_json
        
        end
        
        #
        # Create page support
        #
        app.post "/api/cms/page-support/" do
        
          data_request = body_as_json(ContentManagerSystem::PageSupport)
          data = ContentManagerSystem::PageSupport.create(data_request)
         
          status 200
          content_type :json
          data.to_json          
        
        end
        
        #
        # Updates page support
        #
        app.put "/api/cms/page-support/" do
          
          data_request = body_as_json(ContentManagerSystem::PageSupport)
                              
          if data = ContentManagerSystem::PageSupport.get(data_request.delete(:id).to_i)     
            data.attributes=data_request  
            data.save
          end
      
          content_type :json
          data.to_json        
        
        end
        
        #
        # Deletes page support 
        #
        app.delete "/api/cms/page-support/" do
        
          data_request = body_as_json(ContentManagerSystem::PageSupport)
          
          key = data_request.delete(:id).to_i
          
          if data = ContentManagerSystem::PageSupport.get(key)
            data.destroy
          end
          
          content_type :json
          true.to_json
        
        end

      end
    end
  end
end