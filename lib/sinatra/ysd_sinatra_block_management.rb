require 'uri'
module Sinatra
  module YSD
    module BlockManagement
   
      def self.registered(app)
        
        puts "Registering Sinatra::YSD::BlockManagement"
                    
        #
        # View management page
        #
        app.get "/block-management" do

          # Rehashes all blocks
          ContentManagerSystem::Block.rehash_blocks( Plugins::Plugin.plugin_invoke_all('block_list', {:app => self}) )
          
          load_page 'block_management'.to_sym
          
        end
                
        #
        # Gets a block preview
        #
        ["/block/preview/:block_id"].each do |path|
          
          app.get path do
        
            block = DataMapper.repository(settings.cms_views_repository) do
              ContentManagerSystem::Block.get(params['block_id'])
            end
          
            puts "block: #{block.to_json}"
          
            if block
              puts "invoking : #{block.module_name} 'block_view' #{block.name}"
              BlockRenders.new(block, self).render if block
            end
        
          end
          
        end        
              
      end
    
    end #ViewManagement
  end #YSD
end #Sinatra