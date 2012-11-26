module GuiBlock
  #
  # Term translate
  #
  class TermTranslate

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
    # Element action
    #
    def element_action(context={})
    
      app = context[:app]
      
      app.render_element_action_button({:title => app.t.cms_translations.translate,
                                        :text  => app.t.cms_translations.translate,
                                        :id    => 'term_translate'})
    
    end
    
    #
    # Element action extension
    #
    def element_action_extension(context={})
    
      app = context[:app]
      
      template_path = File.join(File.dirname(__FILE__), '..', 'views', "term-translation-element-action-extension.erb")
      template = Tilt.new(template_path)
      template.render(app)
      
    end

  end #TermTranslate
end #GuiBlock