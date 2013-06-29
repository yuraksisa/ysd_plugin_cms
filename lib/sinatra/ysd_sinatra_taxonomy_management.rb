module Sinatra
  module YSD
    module TaxonomyManagement
       
      def self.registered(app)
                    
        #
        # Taxonomies management page
        #        
        app.get "/taxonomy-management/?*", :allowed_usergroups => ['staff']  do
          load_page :taxonomy_management
        end
      
      end
    
    end #ContentTypeManagement
  end #YSD
end #Sinatra