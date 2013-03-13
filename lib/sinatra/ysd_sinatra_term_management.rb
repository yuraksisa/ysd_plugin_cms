module Sinatra
  module YSD
    module TermManagement
       
      def self.registered(app)
                       
        #
        # Term management page
        #        
        app.get "/term-management/:taxonomy_id/?*" do
          
          if taxonomy = ContentManagerSystem::Taxonomy.get(params[:taxonomy_id])

            aspects = []
            aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::TermTranslate.new, 100, false, false, true, true, 100, true )
            aspects_render = UI::EntityManagementAspectRender.new({app:self}, aspects) 
            
            locals = aspects_render.render(ContentManagerSystem::Term)#content_type)
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