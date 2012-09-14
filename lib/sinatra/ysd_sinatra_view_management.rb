require 'uri'
module Sinatra
  module YSD
    module ViewManagement
   
      def self.registered(app)
        
        puts "Registering Sinatra::YSD::ViewManagement"
                    
        #
        # View management page
        #
        app.get "/view-management" do

          load_page 'view_management'.to_sym
        
        end
               
        #
        # Loads a view as a page
        #
        ["/:view_name",
         "/:view_name/:arguments"].each do |path|
        
          app.get path do
          
            view = DataMapper.repository(settings.cms_views_repository) do
              ContentManagerSystem::View.get(params['view_name'])
            end
          
            pass unless view
                    
            # Creates a content using the view information
            content = ContentManagerSystem::Content.new(view.view_name) 
            content.title = view.view_name
            content.description = view.description         
            content.body = ViewRenders.new(view, self).render(params['arguments'])
          
            page(content) # Renders the content in a page
            
          end
        end
        
        #
        # Gets a view preview
        #
        ["/view/preview/:view_name",
         "/view/preview/:view_name/:arguments"].each do |path|
          
          app.get path do
        
            if view = ContentManagerSystem::View.get(params[:view_name])          
              ViewRenders.new(view, self).render(params[:arguments])
            else
              "Sorry, the views #{params[:view_name]} does not exist"
            end
        
          end
          
        end
      
      end
    
    end #ViewManagement
  end #YSD
end #Sinatra