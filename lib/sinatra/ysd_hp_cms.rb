module Sinatra
  module ContentManagerHelpers
     
    #
    # Render a content action button
    #
    # @param [Hash] option
    #
    #  Information to render the button
    #
    #   :link => the url
    #   :text => the title
    # 
    def render_content_action_button(option)
    
      content_button = <<-CONTENT_BUTTON
         <div class="form-button content-action-button"><a href="#{option[:link]}">#{option[:text]}</a></div>
      CONTENT_BUTTON
      
      if String.method_defined?(:encode)
        content_button.encode!('UTF-8')
      end
      
      content_button
    
    end

    #
    # Render a textarea for editing a template
    #
    # @param [String] The template name
    # @param [String] The label
    # @param [String] class name      
    #
    def render_template_editor(template_name, label, class_name='', rows=15)

      template = if template_name.to_i > 0
                    ContentManagerSystem::Template.get(template_name)
                 else
                    ContentManagerSystem::Template.first({:name => template_name})
                 end

      template_name = template.name

       value = if template
                 template.text
               else
                 ''
               end

       editor = <<-EDITOR 
              <div class="formrow">
                <label for="#{template_name}" class="fieldtitle">#{label}</label>
                <textarea name="#{template_name}" id="#{template_name}" 
                class="fieldcontrol editable_text #{class_name}" rows="#{rows}">#{value}</textarea>
              </div>
       EDITOR

    end

  end
end