require 'ui/ysd_ui_entity_management_aspect_render' unless defined?UI::EntityManagementAspectRender

module Sinatra
  module YSD
    module ContentManagement
   
      def self.registered(app)
       
        app.helpers do 
          
          #
          # Get the content complements
          # 
          def render_content_type_aspects(content_type_id)
            
            context = {:app => self}
            result = {}
                    
            if content_type = ContentManagerSystem::ContentType.get(content_type_id)
              aspects_render=UI::EntityManagementAspectRender.new(context, content_type.aspects) 
              result = aspects_render.render(content_type)
            end            
             
            return result
          
          end
        
        end
       
        #
        # Contents admin
        #
        app.get "/mcontents/?*" do
        
          if not request.accept?'text/html'
            pass
          end        
        
          load_em_page(:contents, nil, false)
        
        end
        
        #
        # Content creation (step one : select content type)
        #
        app.get "/mcontent/new/?" do
        
          load_em_page(:content_new, nil, false)
        
        end
           
        #
        # Create a new content
        #      
        app.get "/mcontent/new/:content_type/?*" do
                    
          # TODO check that the content_type exists
          locals = render_content_type_aspects(params[:content_type])
          locals.store(:url_base, '/mcontent/new')
          locals.store(:action, 'new')
          locals.store(:id, nil)
          locals.store(:content_type, params[:content_type])
          locals.store(:title, "New content (#{params[:content_type]})")
                    
          load_em_page(:content_edition, nil, false, :locals => locals)
        
        end      
        
        #
        # Edit a content
        #
        app.get "/mcontent/edit/:id/?*" do

          # TODO check that the content id exists
          content = ContentManagerSystem::Content.get(params[:id])

          locals = render_content_type_aspects(content.type)
          locals.store(:url_base, '/mcontent/edit')
          locals.store(:action, 'edit')
          locals.store(:id, params[:id])          
          locals.store(:content_type, content.type)
          locals.store(:title, 'Edit content')

          load_em_page(:content_edition, nil, false, :locals => locals)
        
        end
                
        #
        # View a content
        #
        app.get "/mcontent/:id/?*" do

          # TODO check that the content id exists
          content = ContentManagerSystem::Content.get(params[:id])

          locals = render_content_type_aspects(content.type)
          locals.store(:url_base, '/mcontent')
          locals.store(:action, 'view')
          locals.store(:id, params[:id])          
          locals.store(:content_type, content.type)
          locals.store(:title, 'Content')

          load_em_page(:content_edition, nil, false, :locals => locals)
        
        end   
        
        #
        # Manages the content photos (media gallery integration)
        #
        app.get "/mcontent-mphotos/:id/?*" do

          if content = ContentManagerSystem::Content.get(params[:id])
                        
            media_album = nil
            
            if content.album_name.nil? or content.album_name.to_s.strip.length == 0
              content.album_name = "content_#{content.key}"
              content.update
            end
            
            unless media_album = Media::Album.get(content.album_name)                   
              content_type = ContentManagerSystem::ContentType.get(content.type)
              media_album = Media::Album.new(:name => content.key, 
                                             :width => content_type.aspect('album').get_aspect_attribute_value('album_photo_width').to_i, 
                                             :height => content_type.aspect('album').get_aspect_attribute_value('album_photo_height').to_i)
            end
            
            load_page('photo_management'.to_sym, :locals => {:album => media_album})
             
          else
            status 404 # the content does not exist
          end       
        
        end             
              
      end
    
    end #ContentManagement
  end #YSD
end #Sinatra