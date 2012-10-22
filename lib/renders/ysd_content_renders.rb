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
        @display = display
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
     # TODO This routine does not search the content templates in the modules, only in this project    
     #
     def render(locals={})
                  
       content_type_template = nil
       
       if content.type         
         content_type_template = "render-content-#{content.type}"
         content_type_template << "-#{display}" if display
         content_type_template = find_template(content_type_template)
       end
       
       content_template = "render-content"
       content_template << "-#{display}" if display
           
       if content_template_path = (content_type_template || find_template(content_template))
         content_body = build_content_body(locals)
         template = Tilt.new(content_template_path)
         template.render(context, locals.merge({:content => content, :content_body => content_body}))
       else
         puts "Template not found #{content_template_path}"
         ""
       end

      end #render
      
      private
      
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
                            SystemConfiguration::Variable.get_value('site_template_engine') || 'erb'
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
           path = context.get_path(resource_name) #File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'views', resource_name))                                 
           content_template_path = path if not path.nil? and File.exist?(path)
         end
         
         return content_template_path
         
      end
      
     #
     # prepare the complements configured from the content type
     #
     def content_complements()
      
       result = {}
      
       if content_type = ContentManagerSystem::ContentType.get(content.type)
         aspects_render = UIRenders::AspectsRenders.new(context, content_type.get_aspects(context))
         result = aspects_render.render_element(content, content_type) 
       end   
      
       actions = content_edit_link(context, content)
       actions << result[:element_actions] if result.has_key?(:element_actions)
       result.store(:element_actions, actions) 
 
       return result
    
     end
    
     #
     # Creates the content edit link
     #
     def content_edit_link()
      
       app = context[:app]
            
       result = if content and (not content.new?) and content.can_write?(app.user)      

                 edit_content_url = "/mcontent/edit/#{content.key}"
      
                 if app and app.respond_to?(:request) and app.request.respond_to?(:path_info)
                   edit_content_url << "?destination=#{app.request.path_info}"
                 end
                 
                 app.render_content_action_button({:link => edit_content_url, :text => 'Edit'})
                 
               else
                 ""
               end    
    
     end    
     
      
    end #ContentRender
end #ContentRenders