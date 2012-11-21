require 'uri'
require 'ui/ysd_yito_js_pager'

module Sinatra
  module YSD
    module ViewManagement
   
      def self.registered(app)
        
        #
        # View management page
        #
        app.get "/view-management" do
          
          locals = {}
          locals.store(:pagers, UI::Pager.all.to_json)

          load_em_page('view_management'.to_sym, :view, false, :locals => locals)

        end
               
        #
        # Loads a view as a page
        #
        ["/:view_name",
         "/:view_name/page/:page/*",
         "/:view_name/*"].each do |path|
        
          app.get path do
          
            view = ContentManagerSystem::View.first(:url => params['view_name'])
          
            pass unless view

            page = params[:page]

            arguments_start_at = if request.path_info.match /\/page\/\d+/
                                   4
                                 else            
                                   2
                                 end

            arguments = (x=request.path_info.split('/')).slice(arguments_start_at, x.length).join('/')

            page = [params[:page].to_i, 1].max 

            # Creates a content using the view information
            content = ContentManagerSystem::Content.new(view.view_name) 
            content.title = view.title
            content.description = view.description
            content.alias = view.url         
            content.body = CMSRenders::ViewRender.new(view, self).render(page, arguments)
          
            page_from_content(content) # Renders the content in a page
            
          end
        end
        
        #
        # Get a view page
        #
        app.get "/view/:view_name/page/:page/?*" do 

          if view = ContentManagerSystem::View.get(params[:view_name])
            arguments = (x=request.path_info.split('/')).slice(4,x.length).join('/')
            CMSRenders::ViewRender.new(view, self).render(params[:page].to_i, arguments)
          else
            status 404          
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
              CMSRenders::ViewRender.new(view, self).render(1, arguments)
            else
              "Sorry, the views #{params[:view_name]} does not exist"
            end
        
          end
          
        end
      
      end
    
    end #ViewManagement
  end #YSD
end #Sinatra