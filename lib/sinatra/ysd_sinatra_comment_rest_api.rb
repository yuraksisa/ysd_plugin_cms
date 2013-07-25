require 'uri'

#
# Routes
#
module Sinatra
  module YSD
    #
    # REST API to manage comments
    #
    # Comments has a public and a private api. 
    # The public is used by the comment aspect to show and accept comments. 
    # The private is used to manage the comments
    # 
    module CommentRESTApi
    
      def self.registered(app)
     
        # ---------------------- PUBLIC API -----------------------------

        #
        # Retrieve comments
        #
        ["/api/comments/:id",
         "/api/comments/:id/page/:page"].each do |path|
           
           app.get path do
           
             comment_set_id = params[:id]
             page = [params[:page].to_i, 1].max
             page_size = SystemConfiguration::Variable.get_value('cms.comments.page_size', '10').to_i
             limit  = page_size
             offset = (page - 1) * page_size
            
             data, total = ::ContentManagerSystem::Comment.find_comments(comment_set_id, limit, offset)
           
             status 200
             content_type :json
             {:data => data, :total => total}.to_json 
           
           end
                   
        end

        #
        # Creates a new comment
        #
        app.post "/api/comment" do

           request.body.rewind
           comment_request = JSON.parse(URI.unescape(request.body.read))
                      
           comment = ::ContentManagerSystem::Comment.create(comment_request)
           comment.publish_publication
           
           status 200
           content_type :json
           comment.to_json
        
        end   

        # ---------------------- PRIVATE API -----------------------------

        #
        # Retrieve comments
        #
        ["/api/comments",
         "/api/comments/page/:page"].each do |path|
           
           app.post path, :allowed_usergroups => ['staff','editor'] do
           
             page = [params[:page].to_i, 1].max
             page_size = SystemConfiguration::Variable.get_value('cms.comments.page_size', '10').to_i
             limit  = page_size
             offset = (page - 1) * page_size
            
             data, total = ::ContentManagerSystem::Comment.all_and_count(
                {:limit => limit, :offset => offset, 
                 :order => [:date.desc]})
           
             status 200
             content_type :json
             {:data => data, :summary => {:total => total}}.to_json 
           
           end
                   
        end
     
        #
        # Updates a comment
        #
        app.put "/api/comment", :allowed_usergroups => ['staff','editor'] do
           comment_request = body_as_json(ContentManagerSystem::Comment)
           if comment = ContentManagerSystem::Comment.get(comment_request.delete(:id))
             comment.attributes = comment_request
             comment.save
             content_type :json
             comment.to_json
           else
             status 404
           end
        end
        
        #
        # Deletes a comment
        #
        app.delete "/api/comment", :allowed_usergroups => ['staff','editor'] do
           comment_request = body_as_json(ContentManagerSystem::Comment)
           if comment = ContentManagerSystem::Comment.get(comment_request.delete(:id))
             comment.destroy
             content_type :json
             true.to_json
           else
             status 404
           end
        end
        
        #
        # Deletes a comment
        #
        app.delete "/api/comment/:id", :allowed_usergroups => ['staff','editor'] do
           if comment = ContentManagerSystem::Comment.get(params[:id])
             comment.destroy
             content_type :json
             true.to_json
           else
             status 404
           end
        end

        #
        # Publish a comment
        #
        app.post "/api/comment/publish/:id", :allowed_usergroups => ['staff','editor'] do

          if comment = ContentManagerSystem::Comment.get(params[:id])
            comment.publish_publication
            content_type :json
            comment.to_json
          else
            status 404 
          end
        end

        #
        # Confirm a comment
        #
        app.post "/api/comment/confirm/:id", :allowed_usergroups => ['staff','editor'] do

          if comment = ContentManagerSystem::Comment.get(params[:id])
            comment.confirm_publication
            content_type :json
            comment.to_json
          else
            status 404
          end
        end

        #
        # Validate a comment
        #
        app.post "/api/comment/validate/:id", :allowed_usergroups => ['staff','editor'] do

          if comment = ContentManagerSystem::Comment.get(params[:id])
            comment.validate_publication
            content_type :json
            comment.to_json
          else
            status 404
          end

        end     

        #
        # Ban a comment
        #
        app.post "/api/comment/ban/:id", :allowed_usergroups => ['staff','editor'] do

          if comment = ContentManagerSystem::Comment.get(params[:id])
            comment.ban_publication
            content_type :json
            comment.to_json
          else
            status 404
          end

        end

        #
        # Allow a content
        #
        app.post "/api/comment/allow/:id", :allowed_usergroups => ['staff','editor'] do

          if comment = ContentManagerSystem::Comment.get(params[:id])
            comment.allow_publication
            content_type :json
            comment.to_json
          else
            status 404
          end

        end

                       
       end
       
     end # Comment
   end
end # Sinatra