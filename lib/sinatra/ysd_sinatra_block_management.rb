require 'uri'
module Sinatra
  module YSD
    module BlockManagement
   
      def self.registered(app)
        
        puts "Registering Sinatra::YSD::BlockManagement"
                    
        #
        # View management page
        #
        app.get "/block-management", :allowed_usergroups => ['staff'] do

          ContentManagerSystem::Block.rehash_blocks( Plugins::Plugin.plugin_invoke_all('block_list', {:app => self}) )
          
          # Build the regions (theme manager + plugins) 
          regions = Themes::ThemeManager.instance.selected_theme.regions
          regions.concat Plugins::Plugin.plugin_invoke_all(:apps_regions, {:app => self})

          load_page 'block_management'.to_sym, :locals => {:regions => regions}
          
        end
                
        #
        # Gets a block preview
        #
        ["/preview/block/:block_id"].each do |path|
          
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