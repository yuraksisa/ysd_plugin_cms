require 'uri'
module Sinatra
  module YSD
    module TaxonomyManagementRESTApi
       
      def self.registered(app)
               
        app.helpers do
          def prepare_taxonomy(taxonomy)
             taxonomy_content_types = taxonomy.taxonomy_content_types.map do |tct| 
               {:content_type => tct.content_type, :taxonomy_id => tct.taxonomy_id} 
             end                              
             taxonomy.attributes.merge({:taxonomy_content_types => taxonomy_content_types})       
          end
        end   
                
        #
        # Retrieve all taxonomies
        #
        app.get "/taxonomies" do
          data = ContentManagerSystem::Taxonomy.all
          
          content_type :json
          data.to_json
        end
        
        #
        # Retrieve the taxonomies which are asigned to a content type
        #
        app.get "/taxonomy-content-type/:content_type_id" do
        
          data = ContentManagerSystem::TaxonomyContentType.all(:content_type => {:id => params['content_type_id']}) 
          # The following 4 lines are necessary to work on YAML
          data = ContentManagerSystem::TaxonomyContentType.all(:content_type => {:id => params['content_type_id']})
          data.each do |element|
            element.content_type.id
            element.taxonomy.id
          end
          
          content_type :json
          data.to_json
          
        end
        
        #
        # Retrive taxonomies
        #
        ["/taxonomies","/taxonomies/page/:page"].each do |path|
          app.post path do
          
            data=ContentManagerSystem::Taxonomy.all
            begin
              total=ContentManagerSystem::Taxonomy.count
            rescue
              total=ContentManagerSystem::Taxonomy.all.length
            end
            
            # Adds the taxonomies content types information
            data = data.map do |element| 
               prepare_taxonomy(element)
            end

            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Retrieve a taxonomy
        #
        app.get "/taxonomy/:id" do
          
          taxonomy = ContentManagerSystem::Taxonomy.get(params['id'])
          taxonomy = prepare_taxonomy(taxonomy) if taxonomy
          
          status 200
          content_type :json
          taxonomy.to_json
        
        end
        
        #
        # Create a new taxonomy
        #
        app.post "/taxonomy" do
          
          request.body.rewind
          taxonomy_request = JSON.parse(URI.unescape(request.body.read))
          
          # Creates the new content
          taxonomy = ContentManagerSystem::Taxonomy.new(taxonomy_request)
          taxonomy.save
          
          # Return          
          status 200
          content_type :json
          taxonomy.to_json          
        
        end
        
        #
        # Updates a taxonomy
        #
        app.put "/taxonomy" do
                
          request.body.rewind
          taxonomy_request = JSON.parse(URI.unescape(request.body.read))
          taxonomy_request_content_types = taxonomy_request['taxonomy_content_types']
          taxonomy_request.delete('taxonomy_content_types')    
                    
          # Updates the taxonomy
          taxonomy = ContentManagerSystem::Taxonomy.get(taxonomy_request['id'])
          taxonomy.attributes=(taxonomy_request)
          taxonomy.assign_content_types(taxonomy_request_content_types.map { |trct| trct['content_type']['id'] })
          taxonomy.save
                                       
          # Return          
          status 200
          content_type :json
          taxonomy.to_json
        
        
        end
        
        # Deletes a content
        app.delete "/taxonomy" do
        
        end
      
      end
    
    end #ContentTypeManagement
  end #YSD
end #Sinatra