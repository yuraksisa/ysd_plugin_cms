module Sinatra
  module YSD
    module TermManagement
       
      def self.registered(app)
                       
        #
        # Term management page
        #        
        app.get "/term-management/:taxonomy_id/?*" do
          
          # TODO check that the taxonomy id exists
          opts = render_entity_aspects(:term)
          
          load_page(:term_management, :locals => opts)
          
        end
              
      end
    
    end #TermManagement
  end #YSD
end #Sinatra