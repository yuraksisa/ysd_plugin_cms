module GuiBlock
  class AnonymousPublishing

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
      false
    end

    def show_on_view
      false
    end

    def get_aspect_definition(context={})
      return self
    end
    
    #
    #
    #
    def custom(context={}, element, aspect_model)

      app = context[:app]
      
      if app.user.nil? or app.user.belongs_to?('anonymous')
        renderer = ::UI::FieldSetRender.new('anonymouspublishing', app)      
        renderer.render('form') 
      else
        ''
      end      

    end
    
    #
    #
    #
    def custom_extension(context={}, element, aspect_model)

      app = context[:app]

      
      if app.user.nil? or app.user.belongs_to?('anonymous')
        renderer = ::UI::FieldSetRender.new('anonymouspublishing', app)      
        renderer.render('formextension') 
      else
        ''
      end      

    end

    #
    # Information
    #
    def element_info(context={})
      app = context[:app]
      {:id => 'anonymous-publishing', :description => "#{app.t.guiblock.anonymouspublishing.description}"} 
    end

    #
    # Edit Form tab
    #
    def element_form_tab(context={}, aspect_model)
      app = context[:app]
      
      if app.user.belongs_to?(Users::Group.get('anonymous'))
      	info = element_info(context)
        app.render_tab("#{info[:id]}_form", info[:description])
      else
        ''
      end

    end

    #
    # Edition form
    #
    def element_form(context={}, aspect_model)
      
      app = context[:app]
      
      if app.user.belongs_to?(Users::Group.get('anonymous'))
        renderer = ::UI::FieldSetRender.new('anonymouspublishing', app)      
        renderer.render('form', 'em') 
      else
        ''
      end

    end

    #
    # Editing support
    #
    def element_form_extension(context={}, aspect_model)
    
      app = context[:app]

      if app.user.belongs_to?(Users::Group.get('anonymous'))
        renderer = ::UI::FieldSetRender.new('anonymouspublishing', app)      
        renderer.render('formextension', 'em')      
      else       
        ''
      end

    end    

  end
end