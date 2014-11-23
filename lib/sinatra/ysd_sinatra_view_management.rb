require 'uri'
require 'ui/ysd_yito_js_pager'

module Sinatra
  module YSD
    module ViewManagement
   
      def self.registered(app)
        
        app.helpers do

          def extract_view_arguments(page_num, arguments_page, arguments_no_page)

            page = [page_num, 1].max

            arguments_start_at = if request.path_info.match /\/page\/\d+/
                                   arguments_page
                                 else            
                                   arguments_no_page
                                 end
           
            arguments = (x=request.path_info.split('/')).slice(arguments_start_at, x.length).join('/')

            return [page, arguments]

          end

        end

        #
        # View management page
        #
        app.get "/admin/cms/views", :allowed_usergroups => ['staff'] do
          
          locals = {}

          import_extension = partial(:import_extension)
          import_extension << partial(:import_em_extension)

          locals.store(:pagers, UI::Pager.all.to_json)
          locals.store(:import_form, partial(:import, :locals => {:action => '/api/view/import', :accept_import_file => 'text/plain'}))
          locals.store(:import_form_extension, import_extension )
          load_em_page('view_management'.to_sym, :view, false, :locals => locals)

        end
                       
        #
        # Get a view page
        #
        [ "/view/:view_name/page/:page/?*",
          "/view/:view_name/?*"].each do |path| 
          app.get path do

            if view = ContentManagerSystem::View.get(params[:view_name])
              page, arguments = extract_view_arguments(params[:page].to_i, 5, 3)
              begin
                CMSRenders::ViewRender.new(view, self).render(page, arguments)
              rescue ContentManagerSystem::ViewArgumentNotSupplied
                status 404
              end              
            else
              status 404          
            end
          
          end

        end


        #
        # Gets a view preview
        #
        ["/admin/cms/view/preview/:view_name/page/:page/?*",
         "/admin/cms/view/preview/:view_name/?*"].each do |path|
          
          app.get path do
        
            if view = ContentManagerSystem::View.get(params[:view_name])      
              page, arguments = extract_view_arguments(params[:page].to_i, 6, 4)   
              begin
                CMSRenders::ViewRender.new(view, self).render(1, arguments)
              rescue ContentManagerSystem::ViewArgumentNotSupplied
                status 404
              end
            else
              "Sorry, the views #{params[:view_name]} does not exist"
            end
        
          end
          
        end
      
        #
        # Loads a view as a page by its url
        #
        ["/:view_name/page/:page/*",
         "/:view_name/?*"].each do |path|
        
          app.get path do
          
            if params[:view_name] =~ /^[^.]*$/
              pass
            end

            preffixes = Plugins::Plugin.plugin_invoke_all('ignore_path_prefix_cms', {:app => self})
            if params[:view_name].start_with?(*preffixes)
              pass
            end
             
            p "Querying view for #{request.path_info}"

            view = ContentManagerSystem::View.first(:url => params['view_name'])
            pass unless view
            page, arguments = extract_view_arguments(params[:page].to_i, 4, 2)

            page_from_view(view, page, arguments)

          end
        end

      end
    
    end #ViewManagement
  end #YSD
end #Sinatra