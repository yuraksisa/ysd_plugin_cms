require 'ysd-plugins_viewlistener' unless defined?Plugins::ViewListener

#
# Huasi CMS Extension
#
module Huasi

  class CMSExtension < Plugins::ViewListener
    
    # ========= Menu =====================
    
    #
    # It defines the admin menu menu items
    #
    # @return [Array]
    #  Menu definition
    #
    def menu(context={})
      
      app = context[:app]
       
      menu_items = [{:path => '/cms',
                     :options => {:title => app.t.cms_admin_menu.cms_menu,
                                  :description => 'Content management', 
                                  :module => 'cms',
                                  :weight => 10}},
                    {:path => '/cms/contenttypes',
                     :options => {:title => app.t.cms_admin_menu.contenttype_management,
                                  :link_route => "/content-type-management",
                                  :description => 'Manages the content types: creation and update of content types.',
                                  :module => 'cms',
                                  :weight => 6}},
                    {:path => '/cms/contents',
                     :options => {:title => app.t.cms_admin_menu.content_management,
                                  :link_route => "/content-management",
                                  :description => 'Manages the contents: creation and update of contents.',
                                  :module => 'cms',
                                  :weight => 5}},
                    {:path => '/cms/taxonomies',             
                     :options => {:title => app.t.cms_admin_menu.taxonomy_management,
                                  :link_route => "/taxonomy-management",
                                  :description => 'Manages the taxonomies: creation and update of taxonomies.',
                                  :module => 'cms',
                                  :weight => 4}},
                    {:path => '/sbm',
                     :options => {:title => app.t.cms_admin_menu.build_site_menu,
                                  :description => 'Site building',
                                  :module => 'cms',
                                  :weight => 9 }},
                    {:path => '/sbm/blocks',              
                     :options => {:title => app.t.cms_admin_menu.block_management,
                                  :link_route => "/block-management",
                                  :description => 'Manage the blocks. It allows to discover and configure modules blocks.',
                                  :module => 'cms',
                                  :weight => 6}},
                    {:path => '/sbm/views',
                     :options => {:title => app.t.cms_admin_menu.view_management,
                                  :link_route => "/view-management",
                                  :description => 'Manage the views: creation and update of views.',
                                  :module => 'cms',
                                  :weight => 5}}]                      
                     
    end

    # ========= Routes ===================
    
    # routes
    #
    # Define the module routes, that is the url that allow to access the funcionality defined in the module
    #
    #
    def routes(context={})
    
      routes = [{:path => '/content-type-management',
      	         :regular_expression => /^\/content-type-management/, 
                 :title => 'Content type' , 
                 :description => 'Manages the content types: creation and update of content types.',
                 :fit => 1,
                 :module => :cms},
                {:path => '/content-management',
                 :regular_expression => /^\/content-management/, 
                 :title => 'Content', 
                 :description => 'Manages the contents: creation and update of contents.',
                 :fit => 1,
                 :module => :cms},
                {:path => '/taxonomy-management',
                 :regular_expression => /^\/taxonomy-management/, 
                 :title => 'Taxonomy', 
                 :description => 'Manages the taxonomies: creation and update of taxonomies',
                 :fit => 1,
                 :module => :cms },
                {:path => '/term-management/:taxonomy_id',
                 :parent_path => "/taxonomy-management",
                 :regular_expression => /^\/term-management\/.+/,                  
                 :title => 'Term',
                 :description => 'Manage the terms of a taxonomy.',
                 :fit => 1,
                 :module => :cms },
                {:path => '/block-management',
                 :regular_expression => /^\/block-management/, 
                 :title => 'Block', 
                 :description => 'Manage the blocks. It allows to discover and configure modules blocks',
                 :fit => 1,
                 :module => :cms},
                {:path => '/view-management',
                 :regular_expression => /^\/view-management/, 
                 :title => 'View', 
                 :description => 'Manage the views: creation and update of views',
                 :module => :cms},
                {:path => '/content/:page',
                 :regular_expression => /^\/content\/.+/,
                 :title => 'Content',
                 :description => 'Shows a content',
                 :fit => 1,
                 :module => :cms},
                {:path => '/contents/category/:term_id',
                 :regular_expression => /^\/contents\/category\/.+/,
                 :title => 'Contents by category',
                 :description => 'Shows all the contents tagged with the category',
                 :fit => 1,
                 :module => :cms}]
        
    end

    # ========= Page Building ============
    
    #
    # page preprocess
    #
    # @param [Context]
    # @return [Hash]
    #
    #  A Hash where each key represents a variable and the value is an array 
    #
    def page_preprocess(context={})
    
      app = context[:app]
    
      result = {}

      # Blocks : Each hold in its region as key of the result hash
      
      blocks = DataMapper.repository(app.settings.cms_views_repository) do
        ContentManagerSystem::Block.all(:region.not => nil)
      end
      
      blocks.each do |block|
      
        key = block.region.to_sym
       
        result.store(key, []) if not result.has_key?(key)       
        result[key].push(block)
        
      end
      
      puts "page_preprocess : #{result.to_json}"
      
      result
        
    end

    # ========= CMS Hooks ================
   
    # --------- BLOCKS -------------------
    
    # Retrieve all the blocks defined in this module 
    # 
    # @param [Hash] context
    #   The context
    #
    # @return [Array]
    #   The blocks defined in the module
    #
    #   An array of Hash which the following keys:
    #
    #     :name         The name of the block
    #     :module_name  The name of the module which defines the block
    #     :theme        The theme
    #
    def block_list(context={})
      
      blocks = get_views_as_blocks(context) || []
        
    end
    
    # Get a block representation 
    #
    # @param [Hash] context
    #   The context
    #
    # @param [String] block_name
    #   The name of the block
    #
    # @return [String]
    #   The representation of the block
    #
    def block_view(context, block_name)
    
      puts "entering block_view"
      
      result = render_view_as_block(context, block_name) || ''
      
    end

    # ============ Helpers methods ===========
    
    # Retrive the views as a blocks
    # 
    #
    def get_views_as_blocks(context)
    
      app = context[:app]
    
      views = DataMapper.repository(app.settings.cms_views_repository) do
        ContentManagerSystem::View.all
      end
      
      views.map do |view|
        {:name => "view_#{view.view_name}", :module_name => :cms, :theme => app.settings.theme}
      end    
    
    end
    
    # Retrieve a view as a block
    #
    #
    def render_view_as_block(context, block_name)
        
      view_name = block_name.sub(/view_/,'')
      
      puts "block name : #{block_name} view : #{view_name}"
       
      app = context[:app]
    
      view = DataMapper.repository(app.settings.cms_views_repository) do
        ContentManagerSystem::View.get(view_name)
      end
      
      puts "view : #{view.to_json}"
            
      ViewRenders.new(view, app).render if view # Gets the view representation  
                   
    end

  end
end