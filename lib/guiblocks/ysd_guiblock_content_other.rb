module GuiBlock
  class ContentOther

    def weight
      102
    end

    def in_group
      true
    end

    def show_on_new
      false
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
    # Information
    #
    def element_info(context={})
      app = context[:app]
      {:id => 'content_others', :description => "#{app.t.guiblock.others.description}"} 
    end

    #
    # Edit Form tab
    #
    def element_form_tab(context={}, aspect_model)
      app = context[:app]
      if app.user.belongs_to?(Users::Group.get('anonymous'))
        ''
      else
        info = element_info(context)
        app.render_tab("#{info[:id]}_form", info[:description])
      end
    end

    #
    # Edition form
    #
    def element_form(context={}, aspect_model)
      
      app = context[:app]
      
      if app.user.belongs_to?(Users::Group.get('anonymous'))
        ''
      else      
        renderer = ::UI::FieldSetRender.new('content_others', app)      
        renderer.render('form', 'em')     
      end

    end


  end
end
