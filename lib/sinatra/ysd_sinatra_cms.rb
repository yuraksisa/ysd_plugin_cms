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
        # Load a content
        # 
        app.get '/content/:page' do
            
           if not request.accept?'text/html'
             pass
           end
           
           # Gets the content
           
           content = ContentManagerSystem::Content.get(File.join(session[:locale], params[:page])) ||
                     ContentManagerSystem::Content.get(params[:page])
  
           # Get extra data from extensions
           context = {:app => self}          
               
           # Render the content
           if content 
             page(content)
           else
             status 404
           end        
      
        end
        
        #
        # Load a content without layout (for printing ...)
        #       
        app.get '/content/:page/nolayout' do
 
           content = ContentManagerSystem::Content.get(File.join(session[:locale], params[:page])) ||
                     ContentManagerSystem::Content.get(params[:page])
           
           if content           
             page content, :layout => false             
           else
             status 404
           end        
        
        end
        
        #        
        # Show contents which belongs to an specific term
        #
        app.get "/contents/category/:term_id" do
        
           contents = ContentManagerSystem::Content.find_by_term(params['term_id'])
           
           puts "contents : #{contents.inspect}"
                       
           load_page("contents_by_category", :locals => {:contents => contents}) 
                  
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