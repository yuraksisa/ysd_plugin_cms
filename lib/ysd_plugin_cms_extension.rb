# encoding: utf-8
require 'r18n-core'
require 'ysd-plugins_viewlistener' unless defined?Plugins::ViewListener
require 'ui/ysd_ui_page_component' unless defined?UI::PageComponent
require 'fieldsets/ysd_md_commentable'
require 'ysd_md_view_model'
require 'ysd_md_view_model_field'

#
# Huasi CMS Extension
#
module Huasi

  class CMSExtension < Plugins::ViewListener
  include R18n::Helpers

    # ========= Installation =================

    # 
    # Install the plugin
    #
    def install(context={})
            
        SystemConfiguration::Variable.first_or_create({:name => 'cms.author_url'},
                                                      {:value => '/profile/%s', :description => 'author url. Example /profile/%s', :module => :cms})

        SystemConfiguration::Variable.first_or_create({:name => 'cms.comments.pager'},
                                                      {:value => 'page_list', :description => 'comments pager', :module => :cms})

        SystemConfiguration::Variable.first_or_create({:name => 'cms.comments.page_size'},
                                                      {:value => '10', :description => 'comments page size', :module => :cms})

        ContentManagerSystem::ContentType.first_or_create({:id => 'page'},
                                                           {:name => 'Pagina', :description => 'Representa una página web. Es una forma sencilla de gestionar información que no suele cambiar como la página acerca de o condiciones. Suelen mostrarse en el menú.'})
                                                                  
        ContentManagerSystem::ContentType.first_or_create({:id => 'story'},
                                                          {:name => 'Articulo', :description => 'Tiene una estructura similar a la página y permite crear y mostrar contenido que informa a los visitantes del sitio. Notas de prensa, anuncios o entradas informales de blog son creadas como páginas.'})
    
        # Create the primary links menu
        Site::Menu.first_or_create({:name => 'primary_links'},
                                   {:title => 'Primary links menus', :description => 'Primary links menu'})

        # Create the secondary links menu
        Site::Menu.first_or_create({:name => 'secondary_links'},
                                   {:title => 'Secondary links menu', :description => 'Secondary links menu'})

        # Create the members menu
        Site::Menu.first_or_create({:name => 'members'},
                                   {:title => 'Members menu', :description => 'Members menu'})


    end
    
    # ========= Initialization ===========
    
    #
    # Extension initialization (on runtime)
    #
    def init(context={})

      app = context[:app]
      
      [::Model::ViewModel.new(:content, 'content', ContentManagerSystem::Content, :view_template_contents,
         [::Model::ViewModelField.new(:_id, 'id', :string),
          ::Model::ViewModelField.new(:title, 'title', :string),
          ::Model::ViewModelField.new(:path, 'path', :string),
          ::Model::ViewModelField.new(:alias, 'alias', :string),
          ::Model::ViewModelField.new(:summary, 'summary', :string),
          ::Model::ViewModelField.new(:type, 'type', :string),
          ::Model::ViewModelField.new(:creation_date, 'creation_date', :date),
          ::Model::ViewModelField.new(:creation_user, 'creation_user', :string)]),
       ::Model::ViewModel.new(:term, 'term', ContentManagerSystem::Term, :view_template_terms,
         [::Model::ViewModelField.new(:id, 'id', :serial),
          ::Model::ViewModelField.new(:description, 'description', :string)])
       ]

#      [::Model::ViewModel.new(:content, t.entity.content, ContentManagerSystem::Content, :view_template_contents,
#         [::Model::ViewModelField.new(:_id, t.entity_fields.content.id, :string),
#          ::Model::ViewModelField.new(:title, t.entity_fields.content.title, :string),
#          ::Model::ViewModelField.new(:path, t.entity_fieldscontent.path, :string),
#          ::Model::ViewModelField.new(:alias, t.entity_fields.content.alias, :string),
#          ::Model::ViewModelField.new(:summary, t.entity_fields.content.summary, :string),
#          ::Model::ViewModelField.new(:type, t.entity_fields.content.type, :string),
#          ::Model::ViewModelField.new(:creation_date, t.entity_fields.content.creation_date, :date),
#          ::Model::ViewModelField.new(:creation_user, t.entity_fields.content.creation_user, :string)]),
#       ::Model::ViewModel.new(:term, t.entity.term, ContentManagerSystem::Term, :view_template_terms,
#         [::Model::ViewModelField.new(:id, t.entity_fields.term.id, :serial),
#          ::Model::ViewModelField.new(:description, t.entity_fields.term.description, :string)])
#       ]

      # Define the view renders 
      teaser_preprocessor = Proc.new do |data, context, render_options|
                              data.map { |element| CMSRenders::Factory.get_render(element, context, 'teaser').render }
                            end

      slider_preprocessor = Proc.new do |data, context, render_options|
                              data.map { |element| CMSRenders::Factory.get_render(element, context, 'slider').render }
                            end

      term_hierarchy_preprocessor = Proc.new do |data, context, render_options|
                                      separator = render_options['separator'] || "&nbsp;&middot;&nbsp;"
                                      data.map do |element| 
                                        terms = []
                                        #terms << "<img src=\"#{element.photo_url_tiny}\"/>" if element.photo_url_tiny.to_s.strip.length > 0
                                        terms << "<a href=\"#{render_options['prefix']}/#{element.id}\">"
                                        terms << "#{element.description}</a>"
                                        while not element.parent.nil?
                                          element = element.parent
                                          terms << separator
                                          #terms << "<img src=\"#{element.photo_url_tiny}\"/>" if element.photo_url_tiny.to_s.strip.length > 0
                                          terms << "<a href=\"#{render_options['prefix']}/#{element.id}\">#{element.description}</a>"
                                        end
                                        render_result = "<div class=\"term-hierarchy-container #{render_options['container_class']}\">" << terms.reverse.join << "</div>"
                                      end
                                      
                                    end

      ::Model::ViewRender.new(:teaser, 'default teaser', ::Model::ViewStyle::VIEW_STYLE_TEASER, teaser_preprocessor)
      ::Model::ViewRender.new(:slider, 'slider', ::Model::ViewStyle::VIEW_STYLE_TEASER, slider_preprocessor)
      ::Model::ViewRender.new(:term_h, 'term hierarchy', Model::ViewStyle::VIEW_STYLE_TEASER, term_hierarchy_preprocessor)
      ::Model::ViewRender.new(:div, 'div', Model::ViewStyle::VIEW_STYLE_FIELDS)
      ::Model::ViewRender.new(:thumbnails, 'thumbnails', Model::ViewStyle::VIEW_STYLE_FIELDS)
      ::Model::ViewRender.new(:list, 'list', Model::ViewStyle::VIEW_STYLE_FIELDS)
      ::Model::ViewRender.new(:table, 'table', Model::ViewStyle::VIEW_STYLE_FIELDS)


    end

 
    # ========= Aspects ==================
    
    #
    # Retrieve an array of the aspects defined in the plugin
    #
    def aspects(context={})
      
      app = context[:app]
      
      aspects = []
      aspects << ::Plugins::Aspect.new(:comments, app.t.aspect.comments, ContentManagerSystem::FieldSet::Commentable, CommentAspectDelegate.new,
                                       [Plugins::AspectConfigurationAttribute.new(:publishing_workflow_id, 'workflow', 'standard'),
                                        Plugins::AspectConfigurationAttribute.new(:usergroups,'users','user,staff')])
      
      aspects << ::Plugins::Aspect.new(:translation, app.t.aspect.translate, Model::Translatable, CMSTranslationAspectDelegate.new)

      aspects << ::Plugins::Aspect.new(:content_place, app.t.aspect.content_place, ContentManagerSystem::FieldSet::ContentPlace, 
                                       ContentPlaceAspectDelegate.new,
                                       [Plugins::AspectConfigurationAttribute.new(:type, 'content type')])
                                
      return aspects
       
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
                                  :link_route => "/mctypes",
                                  :description => 'Manages the content types: creation and update of content types.',
                                  :module => 'cms',
                                  :weight => 6}},
                    {:path => '/cms/newcontent',
                     :options => {:title => app.t.cms_admin_menu.content_new,
                                  :link_route => "/mcontent/new",
                                  :description => 'Creates a new content.',
                                  :module => 'cms',
                                  :weight => 5}},                                  
                    {:path => '/cms/contents',
                     :options => {:title => app.t.cms_admin_menu.content_management,
                                  :link_route => "/mcontents",
                                  :description => 'Contents explorer.',
                                  :module => 'cms',
                                  :weight => 4}},
                    {:path => '/cms/taxonomies',             
                     :options => {:title => app.t.cms_admin_menu.taxonomy_management,
                                  :link_route => "/taxonomy-management",
                                  :description => 'Manages the taxonomies: creation and update of taxonomies.',
                                  :module => 'cms',
                                  :weight => 3}},
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
                                  :weight => 5}},
                    {:path => '/sbm/menus',               
                     :options => {:title => app.t.site_admin_menu.menu_management,
                                  :link_route => "/menu-management",
                                  :description => 'Manage the menus. It allows to define custom menus.',
                                  :module => :cms,
                                  :weight => 7}}
                    ]                      
                     
    end

    # ========= Routes ===================
    
    # routes
    #
    # Define the module routes, that is the url that allow to access the funcionality defined in the module
    #
    #
    def routes(context={})
    
      routes = [{:path => '/mctypes',
      	         :regular_expression => /^\/mctypes/, 
                 :title => 'Content type' , 
                 :description => 'Manages the content types: creation and update of content types.',
                 :fit => 1,
                 :module => :cms},
                {:path => '/mctype/:type/aspect/:aspect',
                 :parent_path => "/mctypes",
                 :regular_expression => /^\/mctype\/.+\/aspect\/.+/, 
                 :title => 'Content type aspect configuration', 
                 :description => 'Edit the content type/aspect configuration',
                 :fit => 1,
                 :module => :cms},                 
                {:path => '/mcontents',
                 :regular_expression => /^\/mcontents/, 
                 :title => 'Content', 
                 :description => 'Manages the contents: creation and update of contents.',
                 :fit => 1,
                 :module => :cms},
                {:path => '/mcontent/new',
                 :regular_expression => /^\/mcontent\/new/, 
                 :title => 'New content', 
                 :description => 'Create a new content: Choose the content type.',
                 :fit => 2,
                 :module => :cms},
                {:path => '/mcontent/new/:content_type',
                 :parent_path => "/mcontent/new",
                 :regular_expression => /^\/mcontent\/new\/.+/, 
                 :title => 'New content', 
                 :description => 'Create a new content: Complete data.',
                 :fit => 1,
                 :module => :cms},                 
                {:path => '/mcontent/edit/:content_id',
                 :regular_expression => /^\/mcontent\/edit\/.+/, 
                 :title => 'Edit content', 
                 :description => 'Edit a content',
                 :fit => 1,
                 :module => :cms},                 
                {:path => '/mcontent/:content_id',
                 :parent_path => '/mcontents',
                 :regular_expression => /^\/mcontent\/.+/, 
                 :title => 'View content', 
                 :description => 'View a content',
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
                 :module => :cms},
                {:path => '/menu-management',
                 :regular_expression => /^\/menu-management/, 
                 :title => 'Menu', 
                 :description => 'Manages the menus: creation and update of menus',
                 :fit => 1,
                 :module => :cms },
                {:path => '/menu-item-management/:menu_name',
                 :parent_path => "/menu-management",
                 :regular_expression => /^\/menu-item-management\/.+/,                  
                 :title => 'Menu item',
                 :description => 'Manage the items of a menu.',
                 :fit => 1,
                 :module => :cms },
                {:path => '/translate/content/:content_id',
                 :parent_path => '/mcontents',
                 :regular_expression => /^\/translate\/content\/.+/, 
                 :title => 'Content translation', 
                 :description => 'Translate a content',
                 :fit => 1,
                 :module => :translation },
                {:path => '/translate/menuitem/:menuitem_id',
                 :regular_expression => /^\/translate\/menuitem\/.+/, 
                 :title => 'Menu item translation', 
                 :description => 'Translate a menu item',
                 :fit => 1,
                 :module => :translation },                 
                {:path => '/translate/term/:term_id',
                 :regular_expression => /^\/translate\/term\/.+/,                  
                 :title => 'Term translation',
                 :description => 'Translate a term.',
                 :fit => 1,
                 :module => :translation }                 
               ]
        
    end

    # ========= Page Building ============
            
    #
    # Page process
    #
    # @param [Context]
    #
    # @return [Hash]
    #
    #  A Hash where each key represents a variable, the region to insert the content, and the value is an array of blocks
    #
    def page_preprocess(context={})
    
      app = context[:app]
            
      result = {}

      # Retrieve the theme blocks which are positionated in the page
      
      blocks = ContentManagerSystem::Block.all(:region.not => nil, :theme => Themes::ThemeManager.instance.selected_theme.name)
      
      blocks.each do |block|
        
        key = block.region.to_sym

        if not result.has_key?(key)
          result.store(key, [])      
        end

        if block.can_be_shown?(app.user, app.request.path_info) # Add the block only if can be shown

          block_render = CMSRenders::BlockRender.new(block, app).render || ''
          
          if String.method_defined?(:force_encoding)
            block_render.force_encoding('utf-8')
          end

          result[key].push(UI::PageComponent.new({:component => block, 
                                                  :weight => block.weight, 
                                                  :render => block_render })) 
        end

      end
      
      
      return result
        
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
      
      blocks = []
      blocks.concat(get_menus_as_blocks(context))
      blocks.concat(get_breadcrumb_as_block(context))
      blocks.concat(get_views_as_blocks(context))
      blocks.concat(get_contents_as_blocks(context))
      
      return blocks
     
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
       
      app = context[:app]
    
      result = case block_name
      
        when 'site_breadcrumb'
          
          breadcrumb = Site::BreadcrumbBuilder.build(app.request.path_info, context)         
          bc_render = SiteRenders::BreadcrumbRender.new(breadcrumb, context)
          
          bc_render.render
        
        when 'site_adminmenu'
          
          if app.user and app.user.is_superuser?
          
            # Retrieve the admin menu options
            admin_menu = {:name => 'admin_menu', :title => 'Admin menu', :description => 'Administration menu'}
            admin_menu_items = Plugins::Plugin.plugin_invoke_all('menu', context)
                    
            menu = Site::Menu.build(admin_menu, admin_menu_items)
            SiteRenders::MenuRender.new(menu, context).render
          
          end
       
       when /^menu_/
       
         menu_name = block_name.match(/^menu_(.+)/)[1]
         
         if menu = Site::Menu.get(menu_name)
           menu_render = SiteRenders::MenuRender.new(menu, context)
           menu_render.render
         else
           ''
         end
      
       when /^view_/   

         view_name = block_name.sub(/view_/,'')
       
         if view = ContentManagerSystem::View.get(view_name)
            arguments = ""
            if app.request.path_info and app.request.path_info.split('/').length > 2
              arguments = (x=app.request.path_info.split('/')).slice(2,x.length).join('/')
            end
            ::CMSRenders::ViewRender.new(view, app).render(1, arguments) 
         else
            ''
         end
  
       when /^content_/
   
         content_id = block_name.sub(/content_/,'')
         if content = ContentManagerSystem::Content.get(content_id.to_i)
           CMSRenders::ContentRender.new(content, app).render
         else
           ''
         end 


      end

      return result
 
      
    end
        
    # ============ Helpers methods ===========
    
    #
    # Retrieves the menus as blocks
    #
    def get_menus_as_blocks(context)

      blocks = [{:name => 'site_adminmenu',
                 :module_name => :cms,
                 :theme => Themes::ThemeManager.instance.selected_theme.name}]
              
      Site::Menu.all.each do |menu|
      
        blocks << {:name => "menu_#{menu.name}",
                   :module_name => :cms,
                   :theme => Themes::ThemeManager.instance.selected_theme.name}
      
      end

      return blocks

    end

    #
    # Retrieve the breadcrumb as a block
    #
    def get_breadcrumb_as_block(context)
  
      blocks = [{:name => 'site_breadcrumb',
                 :module_name => :cms,
                 :theme => Themes::ThemeManager.instance.selected_theme.name}]

      return blocks
    
    end

    # Retrive the views as blocks
    # 
    #
    def get_views_as_blocks(context)
        
      views = ContentManagerSystem::View.all
      
      views.map do |view|
        {:name => "view_#{view.view_name}", 
         :module_name => :cms, 
         :theme => Themes::ThemeManager.instance.selected_theme.name}
      end    
    
    end
    
    #
    # Retrieve the content as blocks
    #
    def get_contents_as_blocks(context)
    
      ContentManagerSystem::Content.all(:block => true).map do |content|
        {:name => "content_#{content.id}",
         :description => content.title, 
         :module_name => :cms, 
         :theme => Themes::ThemeManager.instance.selected_theme.name}
      end

    end


  end
end