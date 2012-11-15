require 'ysd_md_site' unless defined?Site::Menu

module SiteRenders

  #
  # It's responsible of rendering a Site::Menu instance
  #
  class MenuRender
  
    attr_reader :menu, :context
  
    #
    # @param [Menu] menu
    #   The menu to render
    # @param [Hash] context
    #   The context in which the menu will be rendered
    #
    def initialize(menu, context)
      @menu = menu
      @context = context
    end
    
    #
    # It renders the menu
    #
    def render
    
      start_menu    = "<ul id=\"menu_<%=root[:id]%>\" class=\"menu\">"
      start_submenu = "<li class=\"menuitem\"><a href=\"<%=branch[:link_route]%>\"><%=branch[:title]%></a><ul class=\"submenu submenu-level<%=branch[:level]%>\">"
      menu_item     = "<li class=\"menuitem\"><a href=\"<%=leaf[:link_route]%>\"><%=leaf[:title]%></a></li>"
      end_submenu   = "</ul></li>"
      end_menu      = "</ul>"    
      separator     = "&middot;&nbsp;"
      
      menu = {:id       => @menu.name,
              :title    => @menu.title,
              :children => adapt_children(@menu.root_menu_items.sort{|x,y| y.weight<=>x.weight})}
      
      renderer = TreeRender.new(start_menu, start_submenu, menu_item, end_submenu, end_menu, separator)                  
      renderer.render(menu)
    
    end
      
    private
    
    #
    # Adapt the menu items array to the structure necessary 
    #
    def adapt_children(menu_items)

      app = context[:app]
    
      result = []
      
      menu_items.each do |menu_item|
      
        if app.respond_to?(:session)
           menu_item = menu_item.translate(app.session[:locale])
        end
      
        result << {:id       => menu_item.id,
                   :title    => menu_item.title,
                   :link_route => menu_item.link_route,
                   :children => adapt_children(menu_item.children.sort{|x,y| y.weight<=>x.weight})}
      
      end
      
      result
    
    
    end
    
      
  end
end