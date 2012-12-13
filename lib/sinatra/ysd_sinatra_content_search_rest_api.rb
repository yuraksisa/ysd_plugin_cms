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
       	 
           query_params = extract_request_query_string[:params]
         
           conditions = []
           query_params.each do |property, value|
             case property
               when 'category'
                conditions << Conditions::Comparison.new(property.to_sym, '$in', [value.to_i])
               else
                conditions << Conditions::Comparison.new(property.to_sym, "$eq", value)
             end
           end

           condition = if conditions.length > 1
         	             Conditions::JoinComparison('$and', conditions)
         	           else
         	             if conditions.length == 1
         	               conditions.first
         	             else
         	               nil
         	             end
         	           end

           query = {}
           query.store(:fields, [:key, :title, :photo_url_small])
           query.store(:conditions, condition ) unless condition.nil?
           query.store(:order, [[:title, :desc]])

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