module Sinatra
  module YSD
    module TaxonomyManagement
       
      def self.registered(app)
                    
        #
        # Taxonomies management page
        #        
        app.get "/taxonomy-management/?*" do
          puts "Llego a /taxonomy-management"
          load_page 'taxonomy_management'.to_sym
        end
        
      
      end
    
    end #ContentTypeManagement
  end #YSD
end #Sinatra