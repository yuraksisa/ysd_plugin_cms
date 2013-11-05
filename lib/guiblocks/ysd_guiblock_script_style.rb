module GuiBlock
  class ScriptStyle

    #
    # Information
    #
    def element_info(context={})
      app = context[:app]
      {:id => 'script_style', :description => "#{app.t.guiblock.script_style.description}"} 
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
        renderer = ::UI::FieldSetRender.new('script_style', app)      
        renderer.render('form', 'em')     
      end

    end


  end
end	