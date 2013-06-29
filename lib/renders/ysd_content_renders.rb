require 'ui/ysd_ui_entity_aspect_render' unless defined?UI::EntityAspectRender

module CMSRenders

  #
  # Content Render
  #
  class ContentRender
    
     attr_reader :content
     attr_reader :context
     attr_reader :display
    
     def initialize(content, context, display=nil)       
        @content = if context.respond_to?(:session)
                     content.translate(context.session[:locale])
                   else
                     content
                   end
        @context = context       
        @display = display || content.content_type.display
     end
     
     #
     # It renders the content
     #
     # Looks for the content template 
     #
     # Search order:
     #
     # - content-<type>-<display>.erb (in the theming)
     # - content-<type>-<display>.erb (in views)
     # - content-<display>.erb (in templates)
     # - content-<display>.erb (in views)
     #
     # @param [Hash] locals
     #   Locals to include rendering the content
     #
     # @return [String]
     #   The content rendered
     #
     def render(locals={}, opts=[])
                     
       result = ''
       locals ||= {}
       opts ||= []
       
       if content_template_path = (content_type_template || content_template)
         content_locals = {}
         content_locals.merge!(locals)
         content_locals.merge!(content_complements) if opts.index(:ignore_complements).nil?
         content_locals.merge!(content_blocks) if opts.index(:ignore_blocks).nil?
         content_locals.merge!(content_author)
         content_body = build_content_body(content_locals)
         template = Tilt.new(content_template_path)
         result = template.render(context, content_locals.merge({:content => content, :content_body => content_body}))
       else
         puts "Template not found template: #{content_template_path} display: #{display}"
       end

       if String.method_defined?(:force_encoding)
         result.force_encoding('utf-8')
       end

       return result

      end #render
      
      private
      
      #
      # Get the content type template
      #
      def content_type_template
       
       content_type_template = nil

       if content.type         
         content_type_template_name = "render-content-#{content.type}"
         content_type_template_name << "-#{display}" if (not display.nil?) and (not display.empty?)
         content_type_template = find_template(content_type_template_name)
       end

       return content_type_template

     end
     
     #
     # Get the content template
     #
     def content_template
       
       content_template_name = "render-content"
       content_template_name << "-#{display}" if (not display.nil?) and (not display.empty?)
       content_template = find_template(content_template_name)        

       return content_template

      end

      #
      # Builds the content body 
      #
      # @return [String]
      #
      #  The content body rendered using the template (by default ERB)
      #
      def build_content_body(locals)
         
        template_engine = if (content.class.method_defined?(:template_engine) and content.template_engine.to_s.strip.length > 0)
                            content.template_engine 
                          else
                            SystemConfiguration::Variable.get_value('site.template_engine', 'erb')
                          end
            
        template = Tilt[template_engine].new { content.body }      
        template.render(context, locals) 
      
      end
      
      # Finds the template to render the content
      #
      # @param [String] resource_name
      #   The name of the template
      #
      def find_template(resource_name)
      
         # Search in theme path
         content_template_path = Themes::ThemeManager.instance.selected_theme.resource_path("#{resource_name}.erb",'template','cms') 
         
         # Search in the project
         if not content_template_path
           path = context.get_path(resource_name)                                 
           content_template_path = path if not path.nil? and File.exist?(path)
         end
         
         return content_template_path
         
      end
       
      #
      # Builds the content author
      # 
      def content_author
       
       result = {}

       author = if content.composer_user.nil?
                  content.composer_name
                else
                  content.composer_user.full_name
                end
       author_url = SystemConfiguration::Variable.get_value('cms.author_url', '')
       if (not content.composer_user.nil?) and (not author_url.empty?)
         result.store(:author, "<a class=\"content-author content-composer\" href=\"#{author_url % [content.composer_username]}\">#{author}</a>")
       else
         result.store(:author, "<span class=\"content-author\">#{author}</span>")
       end
       
       return result

      end

     #
     # prepare the complements configured from the content type
     #
     def content_complements
      
       result = {}
      
       if content.content_type 
         aspects = []
         aspects.concat(content.content_type.aspects) 
         aspects_render = UI::EntityAspectRender.new({:app=>context}, aspects) 
         result = aspects_render.render(content, content.content_type) 
       end   
      
       actions = content_edit_link
       actions << result[:element_actions] if result.has_key?(:element_actions)
       result.store(:element_actions, actions) 
 
       return result
    
     end
     
     #
     # Get the blocks configured on the content regions
     #
     def content_blocks

        result = {}

        blocks_hash = ContentManagerSystem::Block.active_blocks(
          Themes::ThemeManager.instance.selected_theme,
          Plugins::Plugin.plugin_invoke(:cms, :apps_regions, context),
          context.user,
          context.request.path_info,
          (content.content_type.nil?)?nil:content.content_type.id)
        
        # To avoid circular
        blocks_hash = blocks_hash.inject({}) do |result, element| 
           result[element[0]] = element[1].select do |block| 
              block.can_be_shown?(context.user, content.alias || content.path, 
                (content.content_type.nil?)?nil:content.content_type.id) 
           end 
           result 
        end

        blocks_hash.each do |region, blocks|
          result[region.to_sym] = []
          blocks.each do |block|
            block_render = CMSRenders::BlockRender.new(block, context).render || ''
            if String.method_defined?(:force_encoding)
              block_render.force_encoding('utf-8')
            end
            result[block.region.to_sym].push({:id => block.name, 
              :title => block.title, :body => block_render}) 
          end
        end

        return result

     end

     #
     # Creates the content edit link
     #
     def content_edit_link()
                       
       result = if content and content.publishing_state and content.can_write?(context.user)   #(not content.new?)  

                 edit_content_url = "/mcontent/edit/#{content.id}"
      
                 if context and context.respond_to?(:request) and context.request.respond_to?(:path_info)
                   edit_content_url << "?destination=#{context.request.path_info}"
                 end
                 
                 context.render_content_action_button({:link => edit_content_url, :text => 'Edit'})
                 
               else
                 ""
               end    
    
     end    
     
      
    end #ContentRender
end #ContentRenders