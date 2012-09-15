module Sinatra
  module YSD
    module ContentManagement
   
      def self.registered(app)
       
        app.helpers do 
          
          #
          # Get the content complements
          # 
          def content_type_aspects(content_type_id)
            
            context = {:app => self}
            result = {}
                    
            if content_type = ContentManagerSystem::ContentType.get(content_type_id)
              result = render_aspects(content_type.get_aspects(context), content_type)
            end            
             
            return result
          
          end
        
        end
       
        #
        # Contents admin
        #
        app.get "/contents/?*" do
        
          if not request.accept?'text/html'
            pass
          end        
        
          load_page :contents
        
        end
        
        #
        # Content creation (step one : select content type)
        #
        app.get "/content/new" do
        
          load_page :content_new
        
        end
           
        #
        # Create a new content
        #      
        app.get "/content/new/:content_type" do
                    
          # TODO check that the content_type exists
          locals = content_type_aspects(params[:content_type])
          locals.store(:url_base, '/content/new')
          locals.store(:action, 'new')
          locals.store(:id, nil)
          locals.store(:content_type, params[:content_type])
          locals.store(:title, "New content (#{params[:content_type]})")
                    
          load_page :content_edition, :locals => locals
        
        end      
        
        #
        # Edit a content
        #
        app.get "/content/edit/:id" do

          # TODO check that the content id exists
          content = ContentManagerSystem::Content.get(params[:id])

          locals = content_type_aspects(content.type)
          locals.store(:url_base, '/content/edit')
          locals.store(:action, 'edit')
          locals.store(:id, params[:id])          
          locals.store(:content_type, content.type)
          locals.store(:title, 'Edit content')

          load_page :content_edition, :locals => locals
        
        end
              
      end
    
    end #ContentManagement
  end #YSD
end #Sinatra