require 'guiblocks/ysd_guiblock_translation_content'

module Huasi
  #
  # Translation aspect
  #
  class CMSTranslationAspectDelegate
    
    attr_reader :content_translation_guiblock

    def initialize
      @content_translation_guiblock = GuiBlock::ContentTranslate.new
    end

    #
    # Custom representation (the comment fields)
    #
    # @param [Hash] the context
    # @param [Object] the element
    # @param [Object] the aspect model (Plugins::ApplicableModelAspect)
    #
    def custom_action(context, element, aspect_model)
      
      content_translation_guiblock.custom_action(context, element, aspect_model) 
    
    end    
    
    
    # ========= Entity management extension ===========
    
    #
    # Content element action
    #
    # @param [Hash] the context
    # @param [Object] the aspect model (Plugins::ApplicableModelAspect)
    #
    def element_action(context={}, aspect_model)
    
       content_translation_guiblock.element_action(context, aspect_model)
    
    end
    
    #
    # Content element action extension
    #
    # @param [Hash] the context
    # @param [Object] the aspect model (Plugins::ApplicableModelAspect)
    #
    def element_action_extension(context={}, aspect_model)
      
      content_translation_guiblock.element_action(context, aspect_model)
    
    end    
    
  end
end  