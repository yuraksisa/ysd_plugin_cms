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
      
        app.before method: :get do
          @force_trailing_slash = SystemConfiguration::Variable.get_value('cms.force_trailing_slash','false').to_bool
        end

        #
        # Try to load a content, view (by its alias) or redirect
        #
        app.get /^[^.]*$/ do
          
          preffixes = Plugins::Plugin.plugin_invoke_all('ignore_path_prefix_cms', {:app => self})
          if request.path_info.empty? or request.path_info.start_with?(*preffixes)
            pass
          end

          p "request.path_info:#{request.path_info}"

          if @force_trailing_slash
            # Request path = request.path_info without last slash
            request_path = request.path_info.end_with?('/') ? request.path_info[0,request.path_info.size-1] : request.path_info
            # Query content or view
            content_conditions = Conditions::JoinComparison.new('$or', 
                                   [Conditions::Comparison.new(:alias, '$eq', URI.unescape(request_path)),
                                    Conditions::Comparison.new(:alias, '$eq', "#{URI.unescape(request_path)}/")])
          else
            request_path = request.path_info
            content_conditions = Conditions::Comparison.new(:alias, '$eq', URI.unescape(request_path))
          end                                

          content = content_conditions.build_datamapper(ContentManagerSystem::Content).first
          content = ContentManagerSystem::Content.content_by_translation_alias(request_path, @force_trailing_slash) if settings.multilanguage_site and content.nil?

          if content              
            if content.can_read?(user) and (not content.is_banned?)
              # Trailing slash compatability with WordPress migration
              front_page = SystemConfiguration::Variable.get_value('site.anonymous_front_page', nil)
              if @force_trailing_slash and !request.path_info.end_with?('/') and content.alias != front_page
                redirect "#{request_path}/", 301
              end  
              @current_content = content
              last_modified (content.last_update || content.creation_date) if user and user.belongs_to?('anonymous') #Cache control
              if settings.multilanguage_site
                page_from_content(content.translate(session[:locale]))
              else
                page_from_content(content)
              end  
            else
              status 404
            end          
          else
             view_path = request.path_info.sub(/\/page\/\d+/, '').sub(/\/\d+$/,'')
             if @force_trailing_slash
               view_path = view_path.end_with?('/') ? view_path[0, view_path.size-1] : view_path
               conditions = Conditions::JoinComparison.new('$or', 
                                     [Conditions::Comparison.new(:url, '$eq', view_path),
                                      Conditions::Comparison.new(:url, '$eq', "#{view_path}/")])
             else
               conditions = Conditions::Comparison.new(:url, '$eq', view_path)
             end  
             if view = conditions.build_datamapper(ContentManagerSystem::View).first
               # Trailing slash compatibility with WordPress migration
               if @force_trailing_slash and !request.path_info.end_with?('/')
                 redirect "#{request_path}/", 301
               end                
               page, arguments = extract_view_path_arguments(view_path, request_path)
               begin
                 page_from_view(view, page, arguments)
               rescue ContentManagerSystem::ViewArgumentNotSupplied
                 status 404
               rescue ContentManagerSystem::ViewPageNotFound
                 status 404                   
               end                
             else
               if @force_trailing_slash
                 conditions = Conditions::JoinComparison.new('$or', 
                                       [Conditions::Comparison.new(:source, '$eq', URI.unescape(request_path)),
                                        Conditions::Comparison.new(:source, '$eq', "#{URI.unescape(request_path)}/")])
               else
                 conditions = Conditions::Comparison.new(:source, '$eq', URI.unescape(request_path))
               end                
               if http_redir = conditions.build_datamapper(ContentManagerSystem::Redirect).first
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