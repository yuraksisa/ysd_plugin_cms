require 'uri'

#
# Routes
#
module Sinatra
  module YSD
    #
    # REST API to manage comments
    #
    module CommentRESTApi
    
      def self.registered(app)
     
        #
        # Creates a new comment
        #
        app.post "/comment" do

           request.body.rewind
           comment_request = JSON.parse(URI.unescape(request.body.read))
                      
           comment = ::ContentManagerSystem::Comment.new(comment_request)
           comment.publish_publication
           
           status 200
           content_type :json
           comment.to_json
        
        end
        
        
        #
        # Retrieve comments
        #
        ["/comments/:id",
         "/comments/:id/page/:page"].each do |path|
           
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
                       
       end
       
     end # Comment
   end
end # Sinatra