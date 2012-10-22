module Huasi
  class CommentAspectDelegate
  
    #
    # Custom representation (the comment fields)
    #
    # @param [Hash] the context
    # @param [Object] the content
    #
    def custom(context={}, element, aspect_model)
    
      app = context[:app]
      
      comment_set = ContentManagerSystem::CommentSet.get_by_reference(element.path) ||
                    ContentManagerSystem::CommentSet.new({:reference => element.path})
      
      template_path = File.join(File.dirname(__FILE__), '..', 'views', "comments-render.erb")
      template = Tilt.new(template_path)
      template.render(app, {:comment_set => comment_set}) 
    
    end
    
    #
    # Custom representation (the comment) 
    #
    # @param [Hash] context
    # @param [Object] object
    #
    def custom_extension(context={}, element, aspect_model)

      app = context[:app]
    
      comment_set = ContentManagerSystem::CommentSet.get_by_reference(element.path) ||
                    ContentManagerSystem::CommentSet.new({:reference => element.path})
      
      template_path = File.join(File.dirname(__FILE__), '..', 'views', "comments-render-extension.erb")
      template = Tilt.new(template_path)
      template.render(app, {:comment_set => comment_set}) 
    
    end    
  
  end
end