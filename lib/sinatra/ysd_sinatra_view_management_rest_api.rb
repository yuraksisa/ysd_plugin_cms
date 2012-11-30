require 'uri'
require 'ysd-plugins_plugin'
require 'ysd_md_view_style'
require 'ysd_md_view_model'

module Sinatra
  module YSD
    module ViewManagementRESTApi
   
      def self.registered(app)
        
        #
        # Retrieve the view models defined
        #
        app.get "/view-models/?" do
        
          view_models = ::Model::ViewModel.all

          status 200
          content_type :json
          view_models.to_json        
        
        end
        
        #
        # Retrieve the view styles
        # 
        app.get "/view-styles/?" do
          
          context = {:app => self}
          
          view_types = ::Model::ViewStyle.all
                  
          status 200
          content_type :json
          view_types.to_json        
                  
        end

        #
        # Retrieve the view renders
        #
        ["/view-renders/:view_style",
          "/view-renders/:view_style/:view_model"].each do |path|
          
          app.get path do
            
            view_style = ::Model::ViewStyle.get(params[:view_style].to_sym)
            view_model = if params[:view_model]
                           ::Model::ViewModel.get(params[:view_model].to_sym)
                         else
                            nil
                         end

            view_renders = ::Model::ViewRender.all(view_style, view_model)
            
            status 200
            content_type :json
            view_renders.to_json
          end
        
        end
        
        #
        # Retrieve all views
        #
        app.get "/views" do

            data = ContentManagerSystem::View.all
            content_type :json
            data.to_json        

        end
        
        # Retrive the contents
        ["/views","/views/page/:page"].each do |path|
          app.post path do

            data=ContentManagerSystem::View.all              

            total = 0            
            begin
              total=ContentManagerSystem::View.count
            rescue
              total = ContentManagerSystem::View.all.length
            end
          
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Create a view
        #
        app.post "/view" do
           
          request.body.rewind
          view_request = JSON.parse(URI.unescape(request.body.read))
          
          # Creates the new content
          view = ContentManagerSystem::View.new(view_request)
          
          puts "view : #{view.inspect} #{view.valid?}"
          
          if not view.save 
            view.errors.each do |e|
              puts e
            end                 
          end       
                    
          # Return          
          status 200
          content_type :json
          view.to_json          
        
        end
        
        # Updates a view
        app.put "/view" do
        
          request.body.rewind
          view_request = JSON.parse(URI.unescape(request.body.read))
          
          # Updates the view
          view = ContentManagerSystem::View.get(view_request['view_name'])         
          view.attributes=(view_request)
          view.save

          # Return          
          content_type :json
          view.to_json
        
        end
        
        # Deletes a view
        app.delete "/view" do

          request.body.rewind
          view_request = JSON.parse(URI.unescape(request.body.read))
          
          #Delete the view
          if view = ContentManagerSystem::View.get(view_request['view_name'])
            view.destroy
          end
          
          content_type :json
          true.to_json
        
        end
        
      
      end
    
    end #ViewManagement
  end #YSD
end #Sinatra