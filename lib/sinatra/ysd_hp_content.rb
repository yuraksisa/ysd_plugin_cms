require 'ui/ysd_ui_page' unless defined?UI::Page

module Sinatra
 module YSD
  #
  # Helper functions to include page generation methods
  #
  module ContentBuilderHelper
       
    #
    # Load a content
    #
    def page_from_content(content, options={})
    
       content_page = UI::Page.new(:title => content.title, 
                                   :author => content.author, 
                                   :keywords => content.keywords, 
                                   :language => content.language, 
                                   :description => content.description, 
                                   :summary => content.summary,
                                   :content => CMSRenders::ContentRender.new(content, self).render(options[:locals]))
      
       page(content_page, options)   

    end
     
  end #SiteHelper
 end #YSD
end #Sinatra 
  