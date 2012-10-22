require 'tempfile'
require 'mime/types'

#
# Routes
#
module Sinatra
  module YSD
    module CommentRESTApi
    
      def self.registered(app)
     
        #
        # Creates a new comment
        #
        app.post "/comment" do

           request.body.rewind
           comment_request = JSON.parse(URI.unescape(request.body.read))
           
           # Make sure the publisher is identified
           if (not comment_request['guest_publisher_email'] or comment_request['guest_publisher_email'].to_s.strip.length == 0) and
              (not comment_request['guest_publisher_name'] or comment_request['guest_publisher_name'].to_s.strip.length == 0) and
              (not comment_request['guest_publisher_website'] or comment_request['guest_publisher_website'].to_s.strip.length == 0) and
              (not comment_request['external_publisher_account'] or comment_request['external_publisher_account'].to_s.strip.length == 0) and
              (not comment_request['publisher_account'] or comment_request['publisher_account'].to_s.strip.length == 0)
             comment_request['publisher_account'] = user.username
           end
           
           puts "#{comment_request.inspect}"
           
           comment = ::ContentManagerSystem::Comment.new(comment_request)
           comment.save
           
           status 200
           content_type :json
           comment.to_json
        
        end
        
        
        #
        # Retrieve comments
        #
        ["/comments/:id","/comments/:id/page/:page"].each do |path|
           
           app.get path do
           
             comment_set_id = params[:id]
             page_size = 10
             limit  = page_size
             offset = if params[:page] 
                        (params[:page] - 1) * page_size
                      else
                        0
                      end

             puts "querying comments : #{comment_set_id}"                 
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