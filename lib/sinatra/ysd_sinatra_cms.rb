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
        # Load a content, view (by its alias) or redirect
        #
        app.get /^[^.]*$/ do
          
          preffixes = Plugins::Plugin.plugin_invoke_all('ignore_path_prefix_cms', {:app => self})
          if request.path_info.empty? or request.path_info.start_with?(*preffixes)
            pass
          end

          # Query content or view
          content = ContentManagerSystem::Content.first(:alias => request.path_info)
          content = ContentManagerSystem::Content.content_by_translation_alias(request.path_info) if content.nil?

          if content              
            if content.can_read?(user) and (not content.is_banned?)
              @current_content = content
              last_modified content.last_update || content.creation_date if user and user.belongs_to?('anonymous') #Cache control
              if settings.multilanguage_site
                page_from_content(content.translate(session[:locale]))
              else
                page_from_content(content)
              end  
            else
              status 404
            end          
          else
             path = request.path_info.sub(/\/page\/\d+/, '').sub(/\/\d+$/,'')
             if view = ContentManagerSystem::View.first(:url => path)
               page, arguments = extract_view_path_arguments(view)
               begin
                 page_from_view(view, page, arguments)
               rescue ContentManagerSystem::ViewArgumentNotSupplied
                 status 404
               end                
             else
               if http_redir = ContentManagerSystem::Redirect.first(:source => request.path_info)
                 redirect http_redir.destination, http_redir.redirection_type
               else
                 pass
               end
             end
          end
        


        end
                      
        #  
        # Load a content by its id (redirect to the url to avoid duplicate urls)
        # 
        app.get '/content/:id' do

           if content = ContentManagerSystem::Content.get(params[:id]) and
              not content.alias.empty?
              redirect content.alias, 301
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