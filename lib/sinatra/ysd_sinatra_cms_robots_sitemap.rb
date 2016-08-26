require 'ysd_md_cms' unless defined?ContentManagerSystem::Template
require 'ysd_core_themes' unless defined?Themes::ThemeManager
require 'tempfile'

module Sinatra
  module YSD
    #
    # Serves the theme css joined with the personalization
    #
  	module RobotsSitemap

      def self.registered(app)

        #
        # Serves /robots.txt
        #
        app.get "/robots.txt" do 
   
          if robots_txt_template = ContentManagerSystem::Template.
                find_by_name("robots_txt")
            dates = []
            dates << robots_txt_template.creation_date.to_time unless robots_txt_template.creation_date.nil?
            dates << robots_txt_template.last_update.to_time unless robots_txt_template.last_update.nil?
            content_type 'text/plain'
            robots_txt_template.text
          else
            robots_txt_path = Themes::ThemeManager.instance.selected_theme.resource_path('/robots.txt', 'static')
            if !robots_txt_path.nil? and File.exists?(robots_txt_path)
               serve_static_resource(request.path_info, 
                File.join(File.dirname(__FILE__), '..', '..', 'static') )            
            else
              status 404  
            end
          end

        end

        #
        # Serves /sitemap.xml
        #
        app.get "/sitemap.xml" do 
   
          if sitemap_xml_template = ContentManagerSystem::Template.
              find_by_name("sitemap_xml")
            dates = []
            dates << sitemap_xml_template.creation_date.to_time unless sitemap_xml_template.creation_date.nil?
            dates << sitemap_xml_template.last_update.to_time unless sitemap_xml_template.last_update.nil?
            content_type 'application/xml'
            sitemap_xml_template.text
          else
            sitemap_xml_path = Themes::ThemeManager.instance.selected_theme.resource_path('/sitemap.xml', 'static')

            if !sitemap_xml_path.nil? and File.exists?(sitemap_xml_path)
              serve_static_resource(request.path_info, 
                 File.join(File.dirname(__FILE__), '..', '..', 'static') )  
            else
              status 404  
            end
          end

        end

      end

  	end
  end
end
