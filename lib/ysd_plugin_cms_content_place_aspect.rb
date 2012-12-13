module Huasi
  #
  # It's a aspect to link to a place defined in a content
  #	 
  class ContentPlaceAspectDelegate
    
    # ======== Content Render ====================

    #
    # Representing the content place when rendering the content
    #
    def custom(context={}, element, aspect_model)

      app = context[:app]
      
      renderer = ::UI::FieldSetRender.new('location', app)
      renderer.render('view','',{:element => element.place})

    end

    #
    # Extension 
    #
    def custom_extension(context={}, element, aspect_model)

      app = context[:app]
      
      renderer = ::UI::FieldSetRender.new('location', app)
      renderer.render('viewextension','',{:element => element.place})

    end
    
    # ========= Aspect config =======================
    
    #
    # The aspect configuration form
    #
    def config(context={}, aspect_model)
      
      app = context[:app]
      template_path = File.expand_path(File.join(File.dirname(__FILE__),'..','views','content_place_aspect_config.erb'))
      template = Tilt.new(template_path)
      the_render = template.render(app)    
      
      if String.method_defined?(:force_encoding)
        the_render.force_encoding('utf-8')
      end

      return the_render

    end

    
    #
    # The aspect configuration form
    #
    def config_extension(context={}, aspect_model)
      
      app = context[:app]
      template_path = File.expand_path(File.join(File.dirname(__FILE__),'..','views','content_place_aspect_config_extension.erb'))
      template = Tilt.new(template_path)
      the_render = template.render(app)    

      if String.method_defined?(:force_encoding)
        the_render.force_encoding('utf-8')
      end

      return the_render
                
    end

    # ======== Content Management ====================

    #
    #
    #
    def element_info(context={})
      app = context[:app]
      {:id => 'contentplace', :description => "#{app.t.content_place.description}"} 
    end
    
    #
    #
    #
    def element_form_tab(context={}, aspect_model)
      app = context[:app]
      info = element_info(context)
      app.render_tab("#{info[:id]}_form", info[:description])
    end
  
    #
    #
    #
    def element_form(context={}, aspect_model)
      app = context[:app]
      renderer = ::UI::FieldSetRender.new('contentplace', app)      
      location_form = renderer.render('form', 'em')
    end

    #
    #
    #
    def element_form_extension(context={}, aspect_model)
      app = context[:app]	
     
      locals = {}

      # aspect configuration
      aspect = aspect_model.aspect('content_place')
      type_filter = aspect.get_aspect_attribute_value('type')
      locals.store(:type_filter, type_filter)

      renderer = ::UI::FieldSetRender.new('contentplace', app)      
      location_form = renderer.render('formextension', 'em', locals)
    end

  end
end