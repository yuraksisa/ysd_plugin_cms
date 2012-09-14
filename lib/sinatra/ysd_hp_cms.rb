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
  
  end
end