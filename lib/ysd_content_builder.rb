require 'ysd_md_cms' unless defined?ContentManagerSystem
require 'ysd-plugins' if not defined?Plugins
require 'ysd_core_themes' unless defined?Themes
require 'renders/ysd_ui_cms_render_factory' unless defined?CMSRenders::Factory
require 'ysd_ui_entity_aspect_render' unless defined?UI::EntityAspectRender

module ContentManagerSystem

  #
  # It's the responsible of generating a site page
  #
  # Usage:
  #
  #  Page.build(content, context)
  #
  #
  class ContentPageBuilder

    attr_reader :variables
    
    attr_reader :title        # The page title
    attr_reader :author       # The page author (meta)
    attr_reader :keywords     # The page keywodrs (meta)
    attr_reader :language     # The page language (meta)
    attr_reader :description  # The page description (meta)
    attr_reader :scripts      # The page scripts (js)
    attr_reader :styles       # The page styles (css)
    attr_reader :content      # The page content

    #
    # Builds a page from it content and the context
    #
    # @param [Content] content
    # @param [Object] context
    #
    def self.build(content, context, options={})
        
      # Creates an instance of the page
      page_builder = ContentPageBuilder.new(Themes::ThemeManager.instance.selected_theme.regions)
    
      # Builds the page
      page_builder.build_page(content, context, options)
              
    end

    # ---------------------------------------------

    #
    # Constructor
    # 
    # @param [Array] regions
    #
    #   The page regions (retrieved from the theme)
    #
    def initialize(regions)
    
      @variables = {}
    
      # Define the regions which will hold the contents    
      regions.each do |region|
        @variables.store(region.to_sym, []) 
      end
    
    end
 
    # Builds a page
    #
    # @param [ContentManagerSystem::Content] content
    #   The content to render
    #
    # @param [Object] context
    #   The context in which the render will be done
    #
    # @param [Hash] locals
    #   Locals
    #
    def build_page(the_content, context, options={})
    
      app    = context[:app]
      locals = options[:locals] || {} 
      layout = if options.has_key?(:layout)
                 if options[:layout]
                   options[:layout]
                 else
                   'blank'
                 end
               else 
                 'page-render'
               end

      # Get the styles 
      @styles = get_styles(context)
      
      # Get the scripts 
      @scripts = get_scripts(context)
                     
      # Executes the page preprocessors to get the sections
      pre_processors(context)
                        
      @title       = the_content.title
      @author      = the_content.author
      @keywords    = the_content.keywords
      @language    = the_content.language
      @description = the_content.description
      
      # Executes the content complements
      locals.merge!(content_complements(context, the_content))
                        
      # Renders the content (obtains an String representation)
      @content = CMSRenders::ContentRender.new(the_content, app).render(locals)
      
      if String.method_defined?(:force_encoding)
        @content.force_encoding('utf-8')
      end
      
      # Renders the page
      page_template_path = find_template(layout)
      page_template = Tilt.new(page_template_path) 
      page_render = page_template.render(app, locals.merge({:page => self}))          
                 
    end
    
    private
    
    #
    # Get the styles
    #
    def get_styles(context)
      
      styles = []
      styles.concat(Plugins::Plugin.plugin_invoke_all('page_style', context))      
      styles.concat(Themes::ThemeManager.instance.selected_theme.styles) 
      styles.uniq!
      
      page_css = styles.map do |style_url|
        "<link type=\"text/css\" rel=\"stylesheet\" href=\"#{style_url}\"/>"
      end  
      
      instance_variable_set("@styles".to_sym, page_css.join) if page_css.length > 0    
      
      page_css.join
    
    end
   
    #
    # Get the scripts
    #
    def get_scripts(context)
    
      scripts = []
      scripts.concat(Themes::ThemeManager.instance.selected_theme.scripts)       
      scripts.concat(Plugins::Plugin.plugin_invoke_all('page_script', context))
      scripts.uniq!
      
      page_scripts = scripts.map do |script_url|
        "<script type=\"text/javascript\" src=\"#{script_url}\"></script>"
      end  
      
      instance_variable_set("@scripts".to_sym, page_scripts.join) if page_scripts.length > 0
      
      page_scripts.join
    
    end
        
    #
    # prepare the complements configured from the content type
    #
    def content_complements(context, content)
      
      result = {}
      
      if content_type = ContentManagerSystem::ContentType.get(content.type)
        aspects_render = UI::EntityAspectRender.new(context, content_type.aspects) #get_aspects_definition(context))
        result = aspects_render.render(content, content_type) 
      end   
      
      actions = content_edit_link(context, content)
      actions << result[:element_actions] if result.has_key?(:element_actions)
      result.store(:element_actions, actions) 
 
      return result
    
    end
    
    #
    # Creates the content edit link
    #
    def content_edit_link(context, content)
      
      app = context[:app]
            
      result = if content and (not content.new?) and content.can_write?(app.user)      

                 edit_content_url = "/mcontent/edit/#{content.key}"
      
                 if app and app.respond_to?(:request) and app.request.respond_to?(:path_info)
                   edit_content_url << "?destination=#{app.request.path_info}"
                 end
                 
                 app.render_content_action_button({:link => edit_content_url, :text => 'Edit'})
                 
               else
                 ""
               end    
    
    end    
    
    #
    # Executes the preprocessors the get the sections of the page
    #
    def pre_processors(context)
    
      app = context[:app]

      variables = Plugins::Plugin.plugin_invoke_all('page_preprocess', context)
      
      # Integrate the variables into 1 Hash    
      variables.each do |var|
        var.each do |key, value|              
          @variables.store(key.to_sym,[]) if not @variables.has_key?(key.to_sym)      
          @variables[key.to_sym].concat(value) 
        end
      end
      
      # Execute the renders for each element of each variable
      @variables.each do |key, value| 
          
          variable_value = value.sort {|x,y| y.weight<=>x.weight}
          render_result = ''
          
          variable_value.each do |element_to_render|  
            if renderer = CMSRenders::Factory.get_render(element_to_render, app)  
              render_result << renderer.render 
            end
          end
 
          if String.method_defined?(:force_encoding)
            render_result.force_encoding('utf-8')
          end
 
          instance_variable_set("@#{key}".to_sym, render_result)
      
      end
    
    end

      
    # Finds the template to render the page
    #
    #
    def find_template(layout)
      
       # Search in theme path
       page_template_path = Themes::ThemeManager.instance.selected_theme.resource_path("#{layout}.erb",'template') 
         
       # Search in the project
       if not page_template_path
         path = get_path(layout)                                 
         page_template_path = path if File.exist?(path)
       end
         
       page_template_path
       
    end

  end #Page
   
end #Site 