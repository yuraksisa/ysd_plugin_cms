module GuiBlock
  #
  # Term translate
  #
  class TermTranslate
   
    #
    # Element action
    #
    def element_action(context={}, aspect_model)
    
      app = context[:app]
      
      app.render_element_action_menuitem({:text  => app.t.cms_translations.translate,
                                          :id    => 'term_translate'})
    
    end
    
    #
    # Element action extension
    #
    def element_action_extension(context={}, aspect_model)
    
      app = context[:app]
      
      template_path = File.join(File.dirname(__FILE__), '..', '..', 'views', "term-translation-element-action-extension.erb")
      template = Tilt.new(template_path)
      template.render(app)
      
    end

  end #TermTranslate
end #GuiBlock