require 'ysd_md_cms' unless defined?ContentManagerSystem::Template
require 'ysd_core_themes' unless defined?Themes::ThemeManager
require 'tempfile'

module Sinatra
  module YSD
    #
    # Serves the theme css joined with the personalization
    #
  	module Webmaster

      def self.registered(app)

        #
        # Serves /sitemap.xml
        #
        app.get "/admin/cms/webaster/contents_sitemap", :allowed_usergroups => ['staff','webmaster'] do 
   
          @domain = SystemConfiguration::Variable.get_value('site.domain')
          @contents = ContentManagerSystem::Content.all(
              :conditions => {publishing_state_id: ContentManagerSystem::PublishingState::PUBLISHED.id}, 
              :order => [:type, :creation_date.desc, :last_update.desc])

          load_page :contents_sitemap

        end

      end

  	end
  end
end
