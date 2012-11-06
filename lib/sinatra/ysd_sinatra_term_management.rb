module Sinatra
  module YSD
    module TermManagement
       
      def self.registered(app)
                       
        #
        # Term management page
        #        
        app.get "/term-management/:taxonomy_id/?*" do
          
          # TODO check that the taxonomy id exists
          
          load_em_page(:term_management, :term, true, :locals => opts)
          
        end
              
      end
    
    end #TermManagement
  end #YSD
end #Sinatra