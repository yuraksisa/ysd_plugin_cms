require 'uri'
module Sinatra
  module YSD
    module ViewManagement
   
      def self.registered(app)
        
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
         "/:view_name/*"].each do |path|
        
          app.get path do
          
            view = ContentManagerSystem::View.first(:url => params['view_name'])
          
            pass unless view
            
            arguments = (x=request.path_info.split('/')).slice(2,x.length).join('/')
                    
            # Creates a content using the view information
            content = ContentManagerSystem::Content.new(view.view_name) 
            content.title = view.title
            content.description = view.description
            content.alias = view.url         
            content.body = CMSRenders::ViewRender.new(view, self).render(arguments)
          
            page(content) # Renders the content in a page
            
          end
        end
        
        #
        # Gets a view preview
        #
        ["/view/preview/:view_name",
         "/view/preview/:view_name/*"].each do |path|
          
          app.get path do
        
            if view = ContentManagerSystem::View.get(params[:view_name])         
              arguments = (x=request.path_info.split('/')).slice(4,x.length).join('/')
              puts "arguments : #{arguments}"
              CMSRenders::ViewRender.new(view, self).render(arguments)
            else
              "Sorry, the views #{params[:view_name]} does not exist"
            end
        
          end
          
        end
      
      end
    
    end #ViewManagement
  end #YSD
end #Sinatra