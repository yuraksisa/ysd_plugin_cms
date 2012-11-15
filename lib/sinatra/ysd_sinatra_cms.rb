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
        # Load a content (by its alias)
        #
        app.get /^[^.]*$/ do
          
          unless content = ContentManagerSystem::Content.first(:conditions => Conditions::Comparison.new(:alias,'$eq',request.path_info))
             pass
          end
          
          if content.can_read?(user) and (not content.is_banned?)
            page_from_content(content)
          else
            status 404
          end

        end
                      
        #  
        # Load a content by its id
        # 
        app.get '/content/:id' do
            
           if not request.accept?'text/html'
             pass
           end
           
           content = ContentManagerSystem::Content.get(File.join(session[:locale], params[:id])) || ContentManagerSystem::Content.get(params[:id])

           if content and (not content.is_banned?)
             if content.can_read?(user)
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