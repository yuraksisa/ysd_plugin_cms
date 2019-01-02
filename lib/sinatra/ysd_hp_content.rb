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
                                   :scripts_source => content.script,
                                   :styles_source => content.style,
                                   :canonical_url => File.join(SystemConfiguration::Variable.get_value('site.domain'), content.alias.gsub('/home','/')),
                                   :content => CMSRenders::ContentRender.new(content, self).render(options[:locals]))
      
       page(content_page, options)   

    end

    #
    # Load a view as a page
    #
    def page_from_view(view, page, arguments, options={})

      begin

        # SEO : Adds the page number to the title and description and summary meta
        title = view.title || ''
        title.strip!
        title << " - #{t.view.page_number(page)}" if page > 1
        description = view.page_description || ''
        description.strip!
        description << " - #{t.view.page_number(page)}" if page > 1
        summary = view.page_summary || ''
        summary.strip!
        summary << " - #{t.view.page_number(page)}" if page > 1

        view_page = UI::Page.new(:title => title,
                                 :author => view.page_author,
                                 :keywords => view.page_keywords,
                                 :language => view.page_language,
                                 :description => description,
                                 :summary => summary,
                                 :scripts_source => view.script,
                                 :styles_source => view.page_style,
                                 :content => CMSRenders::ViewRender.new(view, self).render(page, arguments))
        page(view_page, options)

      rescue ContentManagerSystem::ViewArgumentNotSupplied
        status 404
      end

    end
     
  end #SiteHelper
 end #YSD
end #Sinatra 
  