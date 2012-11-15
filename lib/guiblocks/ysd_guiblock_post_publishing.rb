module GuiBlock
  class PostPublishing

    def weight
      99
    end

    def in_group
      false
    end

    def show_on_new
      true
    end

    def show_on_edit
      true
    end

    def show_on_view
      false
    end

    def get_aspect_definition(context={})
      return self
    end

    #
    # Editing support
    #
    def element_form_extension(context={}, aspect_model)
    
      app = context[:app]

      renderer = ::UI::FieldSetRender.new('postpublishing', app)      
      renderer.render('formextension', 'em')      

    end    

  end #PostPublishing
end #GuiBlock