module GuiBlock
  #
  # Menu item translate
  #
  class MenuItemTranslate

    #def weight
    #  99
    #end

    #def in_group
    #  false
    #end

    #def show_on_new
    #  false
    #end

    #def show_on_edit
    #  true
    #end

    #def show_on_view
    #  false
    #end

    #def render_weigth
    #  99
    #end 

    #def get_aspect_definition(context={})
    #  return self
    #end

    #
    # Menu item element action
    #    
    def menu_item_element_action(context={}, aspect_model)
    
      app = context[:app]
      
      app.render_element_action_button({:title => app.t.cms_translations.translate,
                                        :text  => app.t.cms_translations.translate,
                                        :id    => 'menu_item_translate'})

    
    end
    
    #
    # Menu item element action extension
    #
    def menu_item_element_action_extension(context={}, aspect_model)
    
      app = context[:app]
      
      template_path = File.join(File.dirname(__FILE__), '..', 'views', "menu-item-translation-element-action-extension.erb")
      template = Tilt.new(template_path)
      template.render(app)
    
    end

  end #MenuItemTranslate
end #GuiBlock