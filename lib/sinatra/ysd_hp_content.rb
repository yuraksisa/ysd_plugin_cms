require 'ysd_md_site' unless defined?(Site::Page)

module Sinatra
 module YSD
  #
  # Helper functions to include page generation methods
  #
  module ContentBuilderHelper
      
    # Renders a content getting a web page
    #
    # @param [ContentManagerSystem::Content] content
    #
    # @param [] options
    #  Options to the render
    #
    def page(content, options={})
              
      locals = options[:locals] || {}                
            
      page = ContentManagerSystem::ContentPageBuilder.build(content, {:app => self}, locals)
       
    end
 
    #
    # Loads a sinatra "views" (which can includes metadata)
    #
    # If you need some information in your resource, as title, author, creation
    # date, use this method instead of the templates methods (erb, haml, ...)
    # because it reads the file and extract the metadata.
    # 
    # For example :
    # -------------
    #
    #   If you have a resource, myarticle.erb, you can add it extra information. Then
    #   when you need to render the view, instead of use erb :myarticle, you can
    #   use load_page(:myarticle), and the information will be extracted.
    #   
    #    myarticle.rb
    #
    #     title: Article title
    #     author: me
    #     creation-date: 2011-01-11T10:00:00+01:00
    #     template: erb
    #
    #     here goes the view text
    #
    # 
    # @param [String] view
    #   The view's path
    #
    # @param [Hash] options
    #   A set of options used to render the view 
    #
    def load_page(resource_name, options={})       
      
      begin
            
        resource_name = resource_name.to_s if resource_name.is_a?(Symbol)
              
        if path=get_path(resource_name) # Search the resource in the views path            
          content = ContentManagerSystem::Content.new_from_file(path)           
          page(content, options)        
        else
          #puts "Resource Not Found. Path= #{request.path_info} Resource name= #{resource_name}"
          status 404
        end
        
      rescue Errno::ENOENT => error
          #puts "Resource Not Found. Path= #{request.path_info} Resource name= #{resource_name} Error= #{error}"
          status 404
      end  
    
    end
 
     
  end #SiteHelper
 end #YSD
end #Sinatra 
  