module Sinatra
  module YSD
    module TermManagement
       
      def self.registered(app)
                       
        #
        # Term management page
        #        
        app.get "/term-management/:taxonomy_id/?*" do
          
          if taxonomy = ContentManagerSystem::Taxonomy.get(params[:taxonomy_id])
            locals = {}
            locals.store(:title, t.term_management.title(taxonomy.name))
            load_em_page(:term_management, :term, true, :locals => locals)
          else
            status 404
          end 
          
        end
              
      end
    
    end #TermManagement
  end #YSD
end #Sinatra