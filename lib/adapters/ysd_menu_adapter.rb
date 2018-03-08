module Adapters
  class MenuAdapter

    attr_reader :adapted_menu

    def initialize(menu, locale, default_locale, multilanguage_site=false)
      @locale = locale
      @default_locale = default_locale
      @multilanguage_site = multilanguage_site
      @adapted_menu = {:id       => menu.name,
                       :title    => menu.title,
                       :children => adapt_children(menu.root_menu_items.sort{|x,y| y.weight<=>x.weight})}
    end

    protected

    #
    # Adapt the menu items array to the structure necessary
    #
    def adapt_children(menu_items)

      result = []

      menu_items.each do |menu_item|

        menu_item_link_route = nil

        if menu_item.content
          menu_item_link_route = menu_item.content.alias
        elsif menu_item.link_route
          menu_item_link_route = menu_item.link_route || "/"
        end

        # Translate if necessary
        if @multilanguage_site and @default_locale != @locale
          menu_item = menu_item.translate(@locale)
          if menu_item.content
            content_translation = menu_item.content.translate(@locale)
            # If the content translation alias is defined and it's different from the content alias
            if !content_translation.alias.nil? and !content_translation.alias.empty? and menu_item.content.alias != content_translation.alias
              menu_item_link_route = File.join('/', @locale, content_translation.alias)
            else
              menu_item_link_route = File.join('/', @locale, menu_item_link_route)
            end
          elsif menu_item.link_route
            menu_item_link_route = menu_item.link_route || File.join('/', @locale)
          end
        end

        adapted_item = {:id       => menu_item.id,
                        :title    => menu_item.title,
                        :description => menu_item.description,
                        :link_route => menu_item_link_route,
                        :children => self.adapt_children(menu_item.children.sort{|x,y| y.weight<=>x.weight})}

        result << adapted_item

      end

      result

    end
  end
end