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
      def render(page=1, arguments="")
        
        view_data = get_view_data(page, arguments)
        
        view_url = '/'
        
        if view.url.to_s.strip.length > 0
          view_url << view.url
        else
          view_url << view.view_name
        end

        template_path = find_view_holder
        template = Tilt.new(template_path)
        
        result = template.render(context, {:view => @view, :view_url => view_url, :view_data => view_data, :view_body => render_view_body(view_data), :view_arguments => arguments})
        
        if String.method_defined?(:force_encoding)
          result.force_encoding('utf-8')
        end

        return result
        
      end

      private
      
      #
      # Render the view body
      #
      # @return [String] the rendered body
      #
      def render_view_body(view_data)

        template = Tilt.new(find_template(view))
        result = template.render(context, {:view => @view, :view_data => view_data})
        
        if String.method_defined?(:force_encoding)
          result.force_encoding('utf-8')
        end

        return result

      end
 
      #
      # Get the view data
      #
      # @return [Array] The elements
      #
      def get_view_data(page=1, arguments="")

        data = view.get_data(page, arguments)

        if view.style == 'teaser'
          data[:data].map! { |element| Factory.get_render(element, context, view.render).render }
        end

        return data

      end

      #
      # Finds the template which holds the view
      #
      # @return [String] The holder path
      #
      def find_view_holder

        view_holder_path = Themes::ThemeManager.instance.selected_theme.resource_path("view-holder.erb")

        if not view_holder_path
          path = context.get_path("view-holder")
          view_holder_path = path if not path.nil? and File.exists?(path)
        end

        return view_holder_path

      end

      # Finds the template to render the view
      #
      # @param [View] view
      #   The view to render
      #
      # @param [String] The concrete renderer path
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