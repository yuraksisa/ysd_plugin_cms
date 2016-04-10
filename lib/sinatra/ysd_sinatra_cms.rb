require 'ysd_md_content' if not defined?(ContentManagerSystem)

module Sinatra
  module YSD
    module CMS
  
      def self.registered(app)

        # Add the local folders to the views and translations     
        app.settings.views = Array(app.settings.views).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'views')))
        app.settings.translations = Array(app.settings.translations).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'i18n')))       
        
        # Configuration 
        app.set :cms_views_repository, :default
        app.set :cms_author_url, '' # It represents the author url
        
        #
        # Load a content or view (by its alias)
        #
        app.get /^[^.]*$/ do
          
          preffixes = Plugins::Plugin.plugin_invoke_all('ignore_path_prefix_cms', {:app => self})
          if request.path_info.empty? or request.path_info.start_with?(*preffixes)
            pass
          end

          # Query content or view
          if content = ContentManagerSystem::Content.first(:alias => request.path_info)
            if content.can_read?(user) and (not content.is_banned?)
              @current_content = content
              last_modified content.last_update || content.creation_date if user and user.belongs_to?('anonymous') #Cache control
              page_from_content(content)
            else
              status 404
            end          
          else
             path = request.path_info.sub(/\/page\/\d+/, '') 
             if view = ContentManagerSystem::View.first(:url => path)
               page, arguments = extract_view_path_arguments(view)
               begin
                 result = CMSRenders::ViewRender.new(view, self).render(page, arguments)
                 page_from_view(view, page, arguments)
               rescue ContentManagerSystem::ViewArgumentNotSupplied
                 status 404
               end                
             else
               pass
             end
          end
        


        end
                      
        #  
        # Load a content by its id
        # 
        app.get '/content/:id' do

           if content = ContentManagerSystem::Content.get(params[:id]) and 
              (not content.is_banned?)
             if content.can_read?(user)
               @current_content = content
               last_modified content.last_update || content.creation_date if user and user.belongs_to?('anonymous')  #Cache control
               page_from_content(content)
             else
               status 401
             end
           else
             status 404
           end        
      
        end
        

        #
        # Serves static content from the extension
        #
        app.get "/cms/*" do
                              
           serve_static_resource(request.path_info.gsub(/^\/cms/,''), File.join(File.dirname(__FILE__), '..', '..', 'static'), 'cms')          
            
        end        
     
     
      end  
    
    end # CMS
  end # YSD
end # Sinatra