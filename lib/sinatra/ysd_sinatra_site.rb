module Sinatra
  module YSD
    #
    # It's a Sinatra middleware who manages the web site.
    #
    #  - Shows the home page /
    #  - Helpers to render pages and to load static resources
    #
    #
    # Settings : 
    #
    #  site_anonymous_front_page : Front page for an anonymous user
    #  site_front_page           : Front page for an authenticated user
    #
    #
    module Site
   
      def self.registered(app)
                    
        app.enable :logging
     
        #
        # Home page
        #
        # If there is a connected user
        #   site_front_page variable or site_front_page setting
        #
        app.get '/?' do
        
          front_page = if authenticated?
                         if sfp=SystemConfiguration::Variable.get('site_front_page') 
                           sfp.value
                         else 
                           settings.site_front_page if defined?(settings.site_front_page) 
                         end
                       else 
                         if sfp=SystemConfiguration::Variable.get('site_anonymous_front_page') 
                           sfp.value
                         else
                           settings.site_anonymous_front_page if defined?(settings.site_anonymous_front_page) 
                         end
                       end
          
          if front_page
            status, header, body = call! env.merge("PATH_INFO" => front_page) 
          else
            load_page :frontpage
          end
          
        end        
                
        #
        # Serves static content from the extension (or from the theme)
        #
        app.get "/*" do
            
          serve_static_resource(request.path_info, File.join(File.dirname(__FILE__), '..', '..', 'static') )
            
        end        
             
                                
      end
    
    end # Site
  end # YSD
end # Sinatra