module GuiBlock
  #
  # Template translate
  #
  class TemplateTranslate

    #
    # Menu item element action
    #    
    def element_action(context={}, aspect_model)
    
      app = context[:app]
      
      app.render_element_action_menuitem({:text  => app.t.cms_translations.translate,
        :id => 'template_translate'})

    
    end
    
    #
    # Menu item element action extension
    #
    def element_action_extension(context={}, aspect_model)
   
      app = context[:app]
      
      template_path = File.join(File.dirname(__FILE__), '..', '..', 'views', "template-translation-element-action-extension.erb")
      template = Tilt.new(template_path)
      result = template.render(app)

    end

  end #MenuItemTranslate
end #GuiBlock