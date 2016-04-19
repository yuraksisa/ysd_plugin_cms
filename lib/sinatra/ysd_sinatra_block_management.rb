require 'uri'
module Sinatra
  module YSD
    module BlockManagement
   
      def self.registered(app)
                    
        #
        # View management page
        #
        app.get "/admin/cms/blocks", :allowed_usergroups => ['staff'] do

          ContentManagerSystem::Block.rehash_blocks( Plugins::Plugin.plugin_invoke_all('block_list', {:app => self}) )
          
          regions = Themes::ThemeManager.instance.selected_theme.regions
          regions.concat Plugins::Plugin.plugin_invoke_all(:apps_regions, {:app => self})

          load_em_page(:block_management, nil, false, :locals => {:regions => regions, :blocks_page_size => 20})
          
        end
                
        #
        # Gets a block preview
        #
        ["/admin/cms/block/preview/:block_id"].each do |path|
          
          app.get path, :allowed_usergroups => ['staff'] do
        
            block = DataMapper.repository(settings.cms_views_repository) do
              ContentManagerSystem::Block.get(params['block_id'])
            end
                    
            if block
              CMSRenders::BlockRender.new(block, self).render if block
            end
        
          end
          
        end        
              
      end
    
    end #ViewManagement
  end #YSD
end #Sinatra