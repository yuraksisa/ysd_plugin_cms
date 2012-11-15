module GuiBlock
  #
  # It allows to adapt the metadata information to the Aspects system 
  #
  class Audit

    def weight
      101
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
      true
    end

    def get_aspect_definition(context={})
      return self
    end

    #
    # Information
    #
    def element_info(context={})
      app = context[:app]
      {:id => 'audit', :description => "#{app.t.guiblock.audit.description}"} 
    end

    #
    # Edit Form tab
    #
    def element_form_tab(context={}, aspect_model)
      app = context[:app]
      if app.user.belongs_to?('anonymous')
        ''
      else
        info = element_info(context)
        app.render_tab("#{info[:id]}_template", info[:description])
      end
    end

    #
    # Edition form
    #
    def element_form(context={}, aspect_model)
      
      app = context[:app]
      
      if app.user.belongs_to?('anonymous')
        ''
      else
        renderer = ::UI::FieldSetRender.new('audit', app)      
        renderer.render('view', 'em')     
      end

    end

    #
    # View tab
    #
    def element_template_tab(context={}, aspect_model)
      app = context[:app]
      
      if app.user.belongs_to?('anonymous')
        ''
      else
        info = element_info(context)
        app.render_tab("#{info[:id]}_template", info[:description])
      end

    end    
    
    #
    # View
    #
    def element_template(context={}, aspect_model)
    
      app = context[:app]
      
      if app.user.belongs_to?('anonymous')
        ''
      else    
       renderer = ::UI::FieldSetRender.new('audit', app)      
       renderer.render('view', 'em')
      end          

    end    

  end
end