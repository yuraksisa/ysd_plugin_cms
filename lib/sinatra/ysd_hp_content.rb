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
    def page_from_content(content, display=nil, options={})
    
       content_page = UI::Page.new(:title => content.title, 
                                   :author => content.author, 
                                   :keywords => content.keywords, 
                                   :language => content.language, 
                                   :description => content.description, 
                                   :summary => content.summary,
                                   :content => CMSRenders::ContentRender.new(content, self).render(options[:locals]))
      
       page(content_page, options)   

    end

    #
    # Load a view as a page
    #
    def page_from_view(view, page, arguments, options={})

      # Creates a content using the view information
      begin
        content = ContentManagerSystem::Content.new 
        content.title = view.title
        content.alias = request.path_info
        content.description = view.description       
        content.body = CMSRenders::ViewRender.new(view, self).render(page, arguments)
        
        page_from_content(content, nil, options) 
      rescue ContentManagerSystem::ViewArgumentNotSupplied
        status 404
      end

    end
     
  end #SiteHelper
 end #YSD
end #Sinatra 
  