require 'tilt' unless defined?Tilt

#
# This modules is responsible of rendering view
#
module CMSRenders
    
    #
    # This class is responsible of render a view
    #
    class ViewRender
       attr_reader :view
       attr_reader :context
       attr_reader :display
       
       def initialize(view, context, display=nil)
         @view = view
         @context = context
         @display = display
       end
       
       #
       # Renders the view
       #
       # Search order
       #
       # - view-render-<view.view_name>.erb (in theming)
       # - view-render-<view.type>.erb (in theming)
       # - view-render-<view.type>.erb (in views)
       #
      def render(arguments="")
      
        view_template = find_template(view)
        
        view_data = if view.style == 'teaser'
                      view.get_data(arguments).map { |element| Factory.get_render(element, context, view.render).render }
                    else
                      view.get_data(arguments)
                    end

        template = Tilt.new(view_template)
        view = template.render(context, {:view => @view, :view_data => view_data})
                
        view.force_encoding('utf-8')
        
        return view
        
      end

      private
      
      # Finds the template to render the view
      #
      # @param [View] view
      #   The view to render
      #      
      def find_template(view)
      
        view_template_path = Themes::ThemeManager.instance.selected_theme.resource_path("render-view-#{view.view_name}.erb","template","cms") ||
                             Themes::ThemeManager.instance.selected_theme.resource_path("render-view-#{view.render}.erb","template","cms")
                             
        if not view_template_path
          path = context.get_path("render-view-#{view.render}") #File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'views', "render-view-#{view.render}.erb"))
          view_template_path = path if not path.nil? and File.exist?(path)
        end

        return view_template_path    
      
      end
    
    end #ViewRender
  
end #ViewRenders