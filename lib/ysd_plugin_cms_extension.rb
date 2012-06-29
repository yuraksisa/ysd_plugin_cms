# encoding: UTF-8
require 'ysd-plugins_viewlistener' unless defined?Plugins::ViewListener

#
# Huasi CMS Extension
#
module Huasi

  class CMSExtension < Plugins::ViewListener

    # ========= Installation =================

    # 
    # Install the plugin
    #
    def install(context={})
            
        SystemConfiguration::Variable.first_or_create({:name => 'content_album_name'}, 
                                                      {:value => 'contents', :description => 'album name', :module => :cms}) 
                                                      
        SystemConfiguration::Variable.first_or_create({:name => 'content_album_photo_width'}, 
                                                      {:value => '600', :description => 'photo width', :module => :cms})
                                                      
        SystemConfiguration::Variable.first_or_create({:name => 'content_album_photo_height'},
                                                      {:value => '200', :description => 'photo height', :module => :cms})
                                                      
        ContentManagerSystem::ContentType.first_or_create({:id => 'page'},
                                                           {:name => 'Pagina', :description => 'Representa una página web. Es una forma sencilla de gestionar información que no suele cambiar como la página acerca de o condiciones. Suelen mostrarse en el menú.'})
                                                                  
        ContentManagerSystem::ContentType.first_or_create({:id => 'story'},
                                                          {:name => 'Articulo', :description => 'Tiene una estructura similar a la página y permite crear y mostrar contenido que informa a los visitantes del sitio. Notas de prensa, anuncios o entradas informales de blog son creadas como páginas.'})
    
    end

    
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
    # It gets the style sheets defined in the module
    #
    # @param [Context]
    #
    # @return [Array]
    #   An array which contains the css resources used by the module
    #
    def page_style(context={})
      ['/cms/css/cms.css']     
    end
        
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

      # Retrieve the theme blocks which are positionated in the page
      
      blocks = ContentManagerSystem::Block.all(:region.not => nil, :theme => Themes::ThemeManager.instance.selected_theme.name)
      
      blocks.each do |block|
      
        key = block.region.to_sym
       
        result.store(key, []) if not result.has_key?(key)       
        result[key].push(block)
        
      end
      
      #puts "page_preprocess : #{result.to_json}"
      
      result
        
    end

    # ========= Blocks ===================
    
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
      
      result = render_view_as_block(context, block_name) || ''
      
    end
    
    # ============ Content ===================
    
    #
    # Adds an action in the content action block
    #
    #
    def content_action(context={}, content=nil)
    
      app = context[:app]
            
      puts "content : #{content.inspect} user : #{app.user.inspect} can write: #{content.can_write?(app.user)}"
      
      result = if content #and content.can_write?(app.user)      

                 edit_content_url = "/content-management/edit/#{content.key}"
      
                 if app and app.respond_to?(:request) and app.request.respond_to?(:path_info)
                   edit_content_url << "?destination=#{app.request.path_info}"
                 end
                 
                 app.render_content_action_button({:link => edit_content_url, :text => 'Edit'})
                 
               else
                 ""
               end
    
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
        {:name => "view_#{view.view_name}", :module_name => :cms, :theme => Themes::ThemeManager.instance.selected_theme.name}
      end    
    
    end
    
    # Retrieve a view as a block
    #
    #
    def render_view_as_block(context, block_name)
        
      view_name = block_name.sub(/view_/,'')
      
      #puts "block name : #{block_name} view : #{view_name}"
       
      app = context[:app]
    
      view = DataMapper.repository(app.settings.cms_views_repository) do
        ContentManagerSystem::View.get(view_name)
      end
      
      #puts "view : #{view.to_json}"
            
      ViewRenders.new(view, app).render if view # Gets the view representation  
                   
    end

  end
end