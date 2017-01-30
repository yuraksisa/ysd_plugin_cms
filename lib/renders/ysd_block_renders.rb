require 'tilt' unless defined?Tilt
require 'ysd-plugins' unless defined?Plugins::Plugin
require 'ysd_core_themes' unless defined?Themes::ThemeManager

# encoding: UTF-8
#
# This module is responsible of rendering block
#
module CMSRenders
    
    #
    # Block render
    #
    class BlockRender
       
       attr_reader :block
       attr_reader :context
       attr_reader :display
       
       def initialize(block, context, display=nil)
         @block = block
         @context = context
         @display = display
       end
       
       # It renders the block (gets the block representation)
       #
       #
       def render(arguments="")
           
           block_render  = '' 
           
           begin
             block_content = Plugins::Plugin.plugin_invoke(block.module_name.to_sym, 'block_view', {:app => context}, block.name).join.force_encoding('utf-8')              
             if block_content.strip.length > 0
               block_template_path = find_template
               template = Tilt.new(block_template_path) 
               block_render = template.render(context, :block => @block, :content => block_content, :arguments => arguments)                        
             end           
           rescue
             puts "Error creating block #{block.name}: #{$!} #{$@}"
           end
                        
           block_render  
                          
       end
       
       private
       
       # Finds the template to render the content
       #
       #
       def find_template
      
         # Search in theme path
         block_template_path = Themes::ThemeManager.instance.selected_theme.resource_path('render-block.erb','template','cms') 
         
         # Search in the project
         if block_template_path.nil? or block_template_path.empty?
           path = context.get_path('render-block') #File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'views', 'render-block.erb'))                                 
           block_template_path = path if not path.nil? and File.exist?(path)
         end
         
         block_template_path
       
       end
       
    end #BlockRender
  
end