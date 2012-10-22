module CMSRenders

 module Factory

    #
    # Gets the render
    # 
    def self.get_render(object, app, display=nil)
          
      object_class= object.class.name.match(/(::)?(\w+)$/)[2]
      render_factory(object_class).new(object, app, display)
  
    end

    class << self
    
      private
      
      def render_factory(type)
        class_name= ("#{type.downcase.capitalize}Render").to_sym
        load_render(type) unless ::CMSRenders.const_defined?(class_name)
        ::CMSRenders.const_get(class_name)
      end
      
      def load_render(type)
        require "renders/ysd_#{type.downcase}_renders"
      end
    
    end
  
  end #Factory

end #CMSRenders