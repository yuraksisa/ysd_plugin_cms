require 'ui/ysd_ui_entity_aspect_render'
require 'guiblocks/ysd_guiblock_anonymous_publishing'

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

      locals = {}
      
      # Prepare the comments aspects (ATTENTION ONLY is anonymous publishing is available)
      comments_aspects = []
      comments_aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::AnonymousPublishing.new, {:render_in_group => true})  
      comments_aspects_render = UI::EntityAspectRender.new(context, comments_aspects) 
      locals.merge!(comments_aspects_render.render(element, aspect_model))
      
      # comment Set 
      comment_set = ContentManagerSystem::CommentSet.get_by_reference(element.path) ||
                    ContentManagerSystem::CommentSet.new({:reference => element.path})
      locals.store(:comment_set, comment_set)
      
      # aspect configuration
      aspect = aspect_model.aspect('comments')
      locals.store(:publishing_workflow_id, aspect.get_aspect_attribute_value('publishing_workflow_id'))

      # Renders the comments 
      template_path = File.join(File.dirname(__FILE__), '..', 'views', "comments-render.erb")
      template = Tilt.new(template_path)
      template.render(app, locals) 
    
    end
    
    #
    # Custom representation (the comment) 
    #
    # @param [Hash] context
    # @param [Object] object
    #
    def custom_extension(context={}, element, aspect_model)

      app = context[:app]
    
      locals = {}
            
      # comment set
      comment_set = ContentManagerSystem::CommentSet.get_by_reference(element.path) ||
                    ContentManagerSystem::CommentSet.new({:reference => element.path})
      locals.store(:comment_set, comment_set)

      # pager configuration
      comments_pager = SystemConfiguration::Variable.get_value('cms.comments.pager', 'page_list')
      comments_page_size = SystemConfiguration::Variable.get_value('cms.comments.page_size', '10').to_i
      locals.store(:comments_pager, comments_pager)
      locals.store(:comments_page_size, comments_page_size)
      
      # Render the comment extensions
      template_path = File.join(File.dirname(__FILE__), '..', 'views', "comments-render-extension.erb")
      template = Tilt.new(template_path)
      template.render(app, locals) 
    
    end    
  
    # ========= Aspect configuration =======================
    
    #
    # The aspect configuration form
    #
    def config(context={}, aspect_model)
      
      app = context[:app]
      template_path = File.expand_path(File.join(File.dirname(__FILE__),'..','views','comments_aspect_config.erb'))
      template = Tilt.new(template_path)
      the_render = template.render(app)    

      if String.method_defined?(:force_encoding)
        the_render.force_encoding('utf-8')
      end

      return the_render
                 
    end

    #
    # The aspect configuration form extension
    #
    def config_extension(context={}, aspect_model)
      
      app = context[:app]
      
      aspect = aspect_model.aspect('comments')

      template_path = File.expand_path(File.join(File.dirname(__FILE__),'..','views','comments_aspect_config_extension.erb'))
      template = Tilt.new(template_path)
      the_render = template.render(app, {:publishing_workflow_id => aspect.get_aspect_attribute_value('publishing_workflow_id')})    

      if String.method_defined?(:force_encoding)
        the_render.force_encoding('utf-8')
      end

      return the_render                
    end


  end
end