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
                                   :type => (content.content_type.nil?)?nil:content.content_type.id,
                                   :content => CMSRenders::ContentRender.new(content, self).render(options[:locals]))
      
       page(content_page, options)   

    end

    #
    # Load a view as a page
    #
    def page_from_view(view, page, arguments, options={})

      # Creates a content using the view information
      begin
        view_page = UI::Page.new(:title => view.title,
                                 :author => view.page_author,
                                 :keywords => view.page_keywords,
                                 :language => view.page_language,
                                 :description => view.page_description,
                                 :summary => view.page_summary,
                                 :content => CMSRenders::ViewRender.new(view, self).render(page, arguments))

        page(view_page, options)


      rescue ContentManagerSystem::ViewArgumentNotSupplied
        status 404
      end

    end
     
  end #SiteHelper
 end #YSD
end #Sinatra 
  