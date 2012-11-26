module GuiBlock
  #
  # Content translate
  #
  class ContentTranslate

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
    # Custom representation (the comment fields)
    #
    # @param [Hash] the context
    # @param [Object] the content
    #
    def custom_action(context, element, concept=nil)
      
      app = context[:app]
           
      result = if element and (not element.new?) and element.can_write?(app.user)      

                 translate_url = "/translate/content/#{element.key}"
      
                 if app and app.respond_to?(:request) and app.request.respond_to?(:path_info)
                   translate_url << "?destination=#{app.request.path_info}"
                 end
                 
                 app.render_content_action_button({:link => translate_url, :text => app.t.cms_translations.translate})
                 
               else
                 ""
               end    
    
    end    
    
    
    # ========= Entity management extension ===========
    
    #
    # Content element action
    #
    def element_action(context={}, aspect_model)
    
      app = context[:app]
            
      app.render_element_action_button({:title => app.t.cms_translations.translate, 
                                        :text  => app.t.cms_translations.translate, 
                                        :id    => 'content_translate' })
    
    end
    
    #
    # Content element action extension
    #
    def element_action_extension(context={}, aspect_model)
      
      app = context[:app]
      
      template_path = File.join(File.dirname(__FILE__), '..', 'views', "content-translation-element-action-extension.erb")
      template = Tilt.new(template_path)
      template.render(app)    
    
    end 



  end
end