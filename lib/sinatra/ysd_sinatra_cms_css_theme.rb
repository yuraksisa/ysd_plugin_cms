require 'ysd_md_cms' unless defined?ContentManagerSystem::Template
require 'ysd_core_themes' unless defined?Themes::ThemeManager
require 'tempfile'

module Sinatra
  module YSD
    #
    # Serves the theme css joined with the personalization
    #
  	module CssTheme

      def self.registered(app)

        #
        # Serves /css/style.css
        #
        app.get "/css/style.css" do 
   
          theme_style_path = Themes::ThemeManager.instance.selected_theme.resource_path('/css/style.css', 'static')

          if theme_style_path.nil? or not File.exists?(theme_style_path)
            pass
          end

          unless style_template = ContentManagerSystem::Template.
          	 find_by_name("#{Themes::ThemeManager.instance.selected_theme.name}_theme_style")
        	  serve_static_resource(request.path_info, File.join(File.dirname(__FILE__), '..', '..', 'static') )
          end

          dates = [File.mtime(theme_style_path)]
          dates << style_template.creation_date.to_time unless style_template.creation_date.nil?
          dates << style_template.last_update.to_time unless style_template.last_update.nil?

          last_modified dates.max
          
          content_type 'css', :default => 'application/octet-stream'

          body = File.read(theme_style_path)
          body << style_template.text


        end

      end

  	end
  end
end
