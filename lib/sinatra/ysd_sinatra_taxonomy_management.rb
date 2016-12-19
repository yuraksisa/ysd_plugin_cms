module Sinatra
  module YSD
    module TaxonomyManagement
       
      def self.registered(app)
                    
        #
        # Taxonomies management page
        #        
        app.get "/admin/cms/taxonomy/?*", :allowed_usergroups => ['staff','webmaster']  do
          load_em_page :taxonomy_management, nil, false
        end
      
      end
    
    end #ContentTypeManagement
  end #YSD
end #Sinatra