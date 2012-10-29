require 'ysd_md_site' unless defined?Site::Breadcrumb
require 'tilt' unless defined?Tilt
require 'ysd_core_themes' unless defined?Themes::ThemeManager

module SiteRenders
  #
  # It's responsible of rendering a Site::Breadcrumb instance
  #
  class BreadcrumbRender

    attr_reader :breadcrumb, :context

    def initialize(breadcrumb, context)
      @breadcrumb = breadcrumb
      @context = context
    end
    
    #
    # It renders the bread crumb
    #
    def render
    
       breadcrumb_template_path = find_template

       template = Tilt.new(breadcrumb_template_path)
       breadcrumb_render = template.render(context, :breadcrumb => @breadcrumb)                        
           
       breadcrumb_render
           
    end

    private
       
    # Finds the template to render the content
    #
    #
    def find_template
      
       app = context[:app]
      
       # Search in theme path
       breadcrumb_template_path = Themes::ThemeManager.instance.selected_theme.resource_path('render-breadcrumb.erb','template','site') 
         
       # Search in the project
       if not breadcrumb_template_path
         path = app.get_path('render-breadcrumb') #File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'views', 'render-breadcrumb.erb'))                                 
         breadcrumb_template_path = path if not path.nil? and File.exist?(path)
       end
         
       return breadcrumb_template_path
       
    end

  end
end