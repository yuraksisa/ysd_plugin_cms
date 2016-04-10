# encoding: utf-8
require 'r18n-core'
require 'ysd-plugins_viewlistener' unless defined?Plugins::ViewListener
require 'ui/ysd_ui_page_component' unless defined?UI::PageComponent
require 'fieldsets/ysd_md_commentable'
require 'ysd_md_view_model'
require 'ysd_md_view_model_field'
require 'ysd_md_cms' unless defined?ContentManagerSystem::Template

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

        SystemConfiguration::Variable.first_or_create({:name => 'cms.templates.page_size'},
                                                      {:value => '20', :description => 'templates page size', :module => :cms})

        ContentManagerSystem::ContentType.first_or_create({:id => 'page'},
                                                           {:name => 'Pagina', :description => 'Representa una página web. Es una forma sencilla de gestionar información que no suele cambiar como la página acerca de o condiciones. Suelen mostrarse en el menú.'})
                                                                  
        ContentManagerSystem::ContentType.first_or_create({:id => 'story'},
                                                          {:name => 'Articulo', :description => 'Tiene una estructura similar a la página y permite crear y mostrar contenido que informa a los visitantes del sitio. Notas de prensa, anuncios o entradas informales de blog son creadas como páginas.'})

        ContentManagerSystem::ContentType.first_or_create({:id => 'fragment'},
                                                           {:name => 'Fragmento', :description => 'Representan bloques de información que se pueden mostrar en diferentes páginas. Banners son creados como fragmentos.'})

    
        Site::Menu.first_or_create({:name => 'primary_links'},
                                   {:title => 'Primary links menus', :description => 'Primary links menu'})

        Site::Menu.first_or_create({:name => 'secondary_links'},
                                   {:title => 'Secondary links menu', :description => 'Secondary links menu'})

        Site::Menu.first_or_create({:name => 'members'},
                                   {:title => 'Members menu', :description => 'Members menu'})

        Users::Group.first_or_create({:group => 'editor'},
          {:name => 'Editor', :description => 'Web content editor'})

        ContentManagerSystem::View.first_or_create({:view_name => 'stories'},
        {
         :description => 'Published stories',
         :model_name => 'content',
         :query_conditions => {:operator => '$and', :conditions => [
            {:field => 'type', :operator => '$eq', :value => 'story'},
            {:field => 'publishing_state_id', :operator => '$eq', :value => 'PUBLISHED'}
          ]},
         :query_order => [{:field => 'publishing_date', :order => :desc}],
         :query_arguments => [],
         :style => :teaser,
         :v_fields => [],
         :render => :div,
         :render_options => {},
         :view_limit => 0,
         :pagination => true,
         :ajax_pagination => false,
         :page_size => 10,
         :pager => :default,
         :block => false,
         :url => 'stories'
        })
        
        ContentManagerSystem::View.first_or_create({:view_name => 'last_stories'},
        {
         :description => 'Last published stories',
         :model_name => 'content',
         :query_conditions => {:operator => '$and', :conditions => [
            {:field => 'type', :operator => '$eq', :value => 'story'},
            {:field => 'publishing_state_id', :operator => '$eq', :value => 'PUBLISHED'}
          ]},
         :query_order => [{:field => 'publishing_date', :order => :desc}],
         :query_arguments => [],
         :style => :fields,
         :v_fields => [
            {:field => 'photo_url_small', :image => true, :link => '#{element.path}', 
             :image_alt => '#{element.summary}', :image_class => 'view_div_mini_youtube_img'},
            {:field => 'title', :link => '#{element.path}',
             :class => 'view_div_mini_youtube_title'},
            {:field => 'summary', :class => 'view_div_mini_youtube_body'}
            ],
         :render => :div,
         :render_options => {:container_class => 'view_div_mini_youtube_container',
          :container_element_class => 'view_div_mini_youtube_element'},
         :view_limit => 5,
         :pagination => false,
         :ajax_pagination => false,
         :page_size => 0,
         :pager => :default,
         :block => true
        })


    end
    
    # ========= Initialization ===========
    
    #
    # Extension initialization (on runtime)
    #
    def init(context={})

      app = context[:app]
      
      # View models
      ::Model::ViewModel.new(:content, 'content', ContentManagerSystem::Content, :view_template_contents,
         [::Model::ViewModelField.new(:_id, 'id', :string),
          ::Model::ViewModelField.new(:title, 'title', :string),
          ::Model::ViewModelField.new(:path, 'path', :string),
          ::Model::ViewModelField.new(:alias, 'alias', :string),
          ::Model::ViewModelField.new(:summary, 'summary', :string),
          ::Model::ViewModelField.new(:type, 'type', :string),
          ::Model::ViewModelField.new(:creation_date, 'creation_date', :date),
          ::Model::ViewModelField.new(:creation_user, 'creation_user', :string)])
      
      ::Model::ViewModel.new(:term, 'term', ContentManagerSystem::Term, :view_template_terms,
         [::Model::ViewModelField.new(:id, 'id', :serial),
          ::Model::ViewModelField.new(:description, 'description', :string)])

      ::Model::ViewModel.new(:profile, 'profile', Users::Profile, :view_template_profiles,[])       

      # View renders 
      teaser_preprocessor = Proc.new do |data, context, render_options|
                              data.map { |element| CMSRenders::Factory.get_render(element, context, 'teaser').render({}, [:ignore_complements, :ignore_blocks]) }
                            end

      slider_preprocessor = Proc.new do |data, context, render_options|
                              data.map { |element| CMSRenders::Factory.get_render(element, context, 'justphoto').render({}, [:ignore_complements, :ignore_blocks]) }
                            end

      term_hierarchy_preprocessor = Proc.new do |data, context, render_options|
                                      separator = render_options['separator'] || "&nbsp;&middot;&nbsp;"
                                      data.map do |element| 
                                        terms = []
                                        terms << "<a href=\"#{render_options['prefix']}/#{element.id}\">"
                                        terms << "#{element.description}</a>"
                                        while not element.parent.nil?
                                          element = element.parent
                                          terms << separator
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

    # ========= Page Building ============

    #
    # It gets the style sheets defined in the module
    #
    # @param [Context]
    #
    # @return [Array]
    #   An array which contains the css resources used by the module
    #
    #def page_style(context={})
    #  [
    #    '/css/style.css'         
    #  ]       
    #end

    #
    # Hook to ignore static resources serving
    #
    # @return [Array] the static resources paths to be ignored
    #
    def ignore_static_resources(context={})
      
      ['/css/style.css']

    end

    #
    # Hook the retrieve a layout
    #
    # @return [Array] the layout
    # 
    def page_layout(context={}, layout_name)
      
      if template = ContentManagerSystem::Template.find_by_name(layout_name)
        [template.text]
      else
        ['']
      end

    end

    # ========= Application regions ======
    
    #
    # Retrieve the regions used by the apps 
    #
    def apps_regions(context={})
      [:content_custom, 
       :content_above_body, :content_below_body, :content_left_body, 
       :content_right_body, :content_above_actions]
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
    
    # ========= Pages ====================

    #
    # Return the pages managed by the module
    # @return [Hash] Name - Url
    #
    def public_pages

      pages = {}

      # Add page contents
      ContentManagerSystem::Content.all(:type => {:id => 'page'}).map do |content| 
        pages.store(content.title, content.alias)
      end  

      # Add views
      ContentManagerSystem::View.all(:block => false).map do |view|
        pages.store(view.title, view.url)
      end

      return pages

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
                    {:path => '/cms/newcontent',
                     :options => {:title => app.t.cms_admin_menu.content_new,
                                  :link_route => "/admin/cms/content/new",
                                  :description => 'Creates a new content.',
                                  :module => 'cms',
                                  :weight => 6}},                                    
                    {:path => '/cms/contenttypes',
                     :options => {:title => app.t.cms_admin_menu.contenttype_management,
                                  :link_route => "/admin/cms/content-types",
                                  :description => 'Manages the content types: creation and update of content types.',
                                  :module => 'cms',
                                  :weight => 5}},                                
                    {:path => '/cms/contents',
                     :options => {:title => app.t.cms_admin_menu.content_management,
                                  :link_route => "/admin/cms/contents",
                                  :description => 'Contents explorer.',
                                  :module => 'cms',
                                  :weight => 4}},
                    {:path => '/cms/comments',
                     :options => {:title => app.t.cms_admin_menu.comment_management,
                                  :link_route => "/admin/cms/comments",
                                  :description => 'Comments manager.',
                                  :module => 'cms',
                                  :weight => 3}},                                  
                    {:path => '/cms/taxonomies',             
                     :options => {:title => app.t.cms_admin_menu.taxonomy_management,
                                  :link_route => "/admin/cms/taxonomy",
                                  :description => 'Manages the taxonomies: creation and update of taxonomies.',
                                  :module => 'cms',
                                  :weight => 2}},
                    {:path => '/cms/templates',             
                     :options => {:title => app.t.cms_admin_menu.template_management,
                                  :link_route => "/admin/cms/templates",
                                  :description => 'Manages template: creation and update of template.',
                                  :module => 'cms',
                                  :weight => 1}},       

                    {:path => '/sbm',
                     :options => {:title => app.t.cms_admin_menu.build_site_menu,
                                  :description => 'Site building',
                                  :module => 'cms',
                                  :weight => 9 }},
                    {:path => '/sbm/blocks',              
                     :options => {:title => app.t.cms_admin_menu.block_management,
                                  :link_route => "/admin/cms/blocks",
                                  :description => 'Manage the blocks. It allows to discover and configure modules blocks.',
                                  :module => 'cms',
                                  :weight => 6}},
                    {:path => '/sbm/views',
                     :options => {:title => app.t.cms_admin_menu.view_management,
                                  :link_route => "/admin/cms/views",
                                  :description => 'Manage the views: creation and update of views.',
                                  :module => 'cms',
                                  :weight => 5}},
                    {:path => '/sbm/menus',               
                     :options => {:title => app.t.site_admin_menu.menu_management,
                                  :link_route => "/admin/cms/menu-management",
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
    
      routes = [{:path => '/admin/cms/content-types',
      	         :regular_expression => /^\/admin\/cms\/content-types/, 
                 :title => 'Content type' , 
                 :description => 'Manages the content types: creation and update of content types.',
                 :fit => 1,
                 :module => :cms},
                {:path => '/mctype/:type/:aspect',
                 :parent_path => "/mctypes",
                 :regular_expression => /^\/mctype\/.+\/.+/, 
                 :title => 'Content type aspect configuration', 
                 :description => 'Edit the content type/aspect configuration',
                 :fit => 1,
                 :module => :cms},                 
                {:path => '/admin/cms/contents',
                 :regular_expression => /^\/admin\/cms\/content/, 
                 :title => 'Content', 
                 :description => 'Manages the contents',
                 :fit => 1,
                 :module => :cms},
                {:path => '/admin/cms/content/new/',
                 :regular_expression => /^\/admin\/cms\/content\/new/, 
                 :title => 'New content', 
                 :description => 'Create a new content: Choose the content type.',
                 :fit => 2,
                 :module => :cms},
                {:path => '/admin/cms/content/new/:content_type',
                 :parent_path => "/admin/site/cms/new/content",
                 :regular_expression => /^\/admin\/cms\/content\/new\/.+/, 
                 :title => 'New content', 
                 :description => 'Create a new content: Complete data.',
                 :fit => 1,
                 :module => :cms},                 
                {:path => '/admin/cms/content/edit/:content_id',
                 :regular_expression => /^\/admin\/cms\/content\/edit\/.+/, 
                 :title => 'Edit content', 
                 :description => 'Edit a content',
                 :fit => 1,
                 :module => :cms},                 
                {:path => '/admin/cms/taxonomy',
                 :regular_expression => /^\/admin\/cms\/taxonomy/, 
                 :title => 'Taxonomy', 
                 :description => 'Manages the taxonomies: creation and update of taxonomies',
                 :fit => 1,
                 :module => :cms },
                {:path => '/admin/cms/terms/:taxonomy_id',
                 :parent_path => "/admin/cms/taxonomy",
                 :regular_expression => /^\/admin\/cms\/terms\/.+/,                  
                 :title => 'Term',
                 :description => 'Manage the terms of a taxonomy.',
                 :fit => 1,
                 :module => :cms },
                {:path => '/admin/cms/templates',
                 :regular_expression => /^\/admin\/cms\/templates/, 
                 :title => 'Templates', 
                 :description => 'Manages templates: creation and update of templates',
                 :fit => 1,
                 :module => :cms }, 
                {:path => '/admin/cms/comments',
                 :regular_expression => /^\/admin\/cms\/comments/, 
                 :title => 'Templates', 
                 :description => 'Manages comments: creation and update of templates',
                 :fit => 1,
                 :module => :cms },                                   
                {:path => '/admin/cms/blocks',
                 :regular_expression => /^\/admin\/cms\/blocks/, 
                 :title => 'Block', 
                 :description => 'Manage the blocks. It allows to discover and configure modules blocks',
                 :fit => 1,
                 :module => :cms},
                {:path => '/admin/cms/views',
                 :regular_expression => /^\/admin\/cms\/views/, 
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
                {:path => '/admin/cms/menu-management',
                 :regular_expression => /^\/admin\/cms\/menu-management/, 
                 :title => 'Menu', 
                 :description => 'Manages the menus: creation and update of menus',
                 :fit => 1,
                 :module => :cms },
                {:path => '/admin/cms/menu-item-management/:menu_name',
                 :parent_path => "/menu-management",
                 :regular_expression => /^\/admin\/cms\/menu-item-management\/.+/,                  
                 :title => 'Menu item',
                 :description => 'Manage the items of a menu.',
                 :fit => 1,
                 :module => :cms },
                {:path => '/admin/cms/translate/content/:content_id',
                 :parent_path => '/admin/cms/contents',
                 :regular_expression => /^\/admin\/cms\/translate\/content\/.+/, 
                 :title => 'Content translation', 
                 :description => 'Translate a content',
                 :fit => 1,
                 :module => :translation },
                {:path => '/admin/cms/translate/menuitem/:menuitem_id',
                 :regular_expression => /^\/admin\/cms\/translate\/menuitem\/.+/, 
                 :title => 'Menu item translation', 
                 :description => 'Translate a menu item',
                 :fit => 1,
                 :module => :translation },                 
                {:path => '/admin/cms/translate/term/:term_id',
                 :regular_expression => /^\/admin\/cms\/translate\/term\/.+/,                  
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
    def page_preprocess(page, context={})
    
      app = context[:app]
            
      result = {}

      # Retrieve the theme blocks which are positionated in the page
      
      blocks = ContentManagerSystem::Block.all(
        :region => Themes::ThemeManager.instance.selected_theme.regions, 
        :theme => Themes::ThemeManager.instance.selected_theme.name)
      
      blocks.each do |block|
        
        key = block.region.to_sym

        if not result.has_key?(key)
          result.store(key, [])      
        end

        if block.can_be_shown?(app.user, app.request.path_info, page.type) 

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
          
          preffixes = Plugins::Plugin.plugin_invoke_all('ignore_path_prefix_breadcrumb', {:app => self})
          
          if !app.request.path_info.empty? and app.request.path_info.start_with?('/admin')
            breadcrumb = Site::BreadcrumbBuilder.build(app.request.path_info, context)         
            bc_render = SiteRenders::BreadcrumbRender.new(breadcrumb, context)
            bc = bc_render.render          
          elsif app.request.path_info.empty? or app.request.path_info.start_with?(*preffixes)
            bc = ''
          else
            path = app.request.path_info
            if path.match /\/page\/\d+/
              path.sub!(/\/page\/\d+/,'')
            end
            home_page_path = SystemConfiguration::Variable.get_value('site.anonymous_front_page', nil)
            bc = app.t.breadcrumb.home

            if home_page_path != path
              path_array = path.split('/')
              result = ""
              summary = "\\"
              bc = path_array.slice(0, path_array.size-1).inject("") do |result, item| 
                     if item.empty?
                       result << "<a href=\"/\">#{app.t.breadcrumb.home}</a>"
                       result
                     else 
                       result << "<span class=\"breadcrumb_separator\"> &gt; </span> " unless result.empty?
                       result << "<a href=\"#{summary}#{item}\">#{item.capitalize.gsub(/-/,' ')}</a>"
                       summary << "#{item}\\" 
                       result
                     end
                   end
              if path_array.size > 1
                bc << " <span class=\"breadcrumb_separator\"> &gt; </span> <span class=\"breadcrumb_last\">#{path_array.last.capitalize.gsub(/-/,' ')}</span>"
              end
            end
          end          

          bc


        when 'site_adminmenu'
          
          if app.user and app.user.is_superuser?
          
            # Retrieve the admin menu options
            admin_menu = {:name => 'admin_menu', :title => 'Admin menu', :description => 'Administration menu'}
            admin_menu_items = Plugins::Plugin.plugin_invoke_all('menu', context)
                    
            menu = Site::Menu.build(admin_menu, admin_menu_items)
            menu.language_in_routes = false
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