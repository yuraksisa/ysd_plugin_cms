require 'ysd_md_content'

module Sinatra
  module YSD
    #
    # Content Search REST API
    #
    module ContentSearchRESTApi

     def self.registered(app)
       
       #
       # Search content (AJAX SEARCH)
       #
       ["/search/content/?*",
       	"/search/content/:text/?*"].each do |path|
         app.get path do
       	 
           query = {}
           query.store(:fields, [:id, :title, :photo_url_small])
           query.store(:order, [:title.asc])

           if query_params = extract_request_query_string[:params]
             conditions = {}
             query_params.each do |property, value|
               case property
                 when 'category'
                   conditions[:content_categories] = {:category => {:id => value.to_i}}
                 when 'type'
                   conditions[:content_type] = {:id => value}
                 else
                   conditions.store(property.to_sym, value)
                 end
             end
             query.store(:conditions, conditions ) unless conditions.empty?
           end

           data = ContentManagerSystem::Content.all(query)
         
           status 200
           content_type :json
           data.to_json

         end

       end

     end

    end
  end
end