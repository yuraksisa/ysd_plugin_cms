require 'uri'

module Sinatra
  module YSD
    module ViewManagement
   
      def self.registered(app)
        
        app.helpers do

          def extract_view_path_arguments(view)
            path = request.path_info
            if !view.url.nil? or !view.url.empty?
              if path.start_with?(view.url)
                length = path.length-1
                arguments = path[view.url.length, length]
                # No arguments
                if arguments.nil?
                  return [1, '']
                end
                if arguments.match /\/page\/\d+/
                  arguments_array = arguments.split('/')
                  arguments_array.delete_at(0) if arguments_array.size > 0 #First element empty
                  return [arguments_array[arguments_array.index('page')+1].to_i, arguments.sub(/\/page\/\d+/,'')]
                else 
                  return [1, arguments]
                end
              end
            end
          end 

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
        app.get "/admin/cms/views", :allowed_usergroups => ['staff','webmaster'] do
          
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
          
          app.get path, :allowed_usergroups => ['staff','webmaster'] do
        
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
      
      end
    
    end #ViewManagement
  end #YSD
end #Sinatra