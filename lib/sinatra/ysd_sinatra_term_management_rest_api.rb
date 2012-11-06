require 'uri'
require 'json'

module Sinatra
  module YSD
    #
    # Term management REST API
    #
    module TermManagementRESTApi
       
      def self.registered(app)
        
        #
        # Retrieve terms
        #
        app.get "/terms/?" do
          
          search_term_request = extract_request_query_string
          
          opts = {}
          if search_term_request.has_key?('tag')
            opts.store(:conditions, {:description.like => "#{search_term_request['tag']}%"})
          end 

          data=ContentManagerSystem::Term.all(opts)

          content_type :json
          data.to_json
          
        end

        #
        # Retrieve the list of terms which belongs to a taxonomy
        #
        app.get "/terms/:taxonomy_id" do
          
          data=ContentManagerSystem::Term.all({:conditions => {:taxonomy => {:id => params['taxonomy_id']}}, :order => [:parent_id.desc,:weight.desc]})
          
          content_type :json
          data.to_json
        
        end
        
        #
        # Retrive the term parent candidadates
        #
        ["/terms-parent-candidate/:taxonomy_id","/terms-parent-candidate/:taxonomy_id/:term_id"].each do |path|
        
          app.get path do
            data=ContentManagerSystem::Term.all({:conditions => {:taxonomy => {:id => params['taxonomy_id']}}, :order => [:parent_id.desc,:weight.desc]})
          
            content_type :json
            data.to_json          
          end
        
        end
        
        #
        # Retrive terms
        #
        ["/terms/:taxonomy_id","/terms/:taxonomy_id/page/:page"].each do |path|
          app.post path do
          
            data=ContentManagerSystem::Term.all({:conditions => {:taxonomy => {:id => params['taxonomy_id']}}, :order => [:parent_id.desc,:weight.desc]})
            
            begin
              total=ContentManagerSystem::Term.count(:taxonomy => {:id => params['taxonomy_id']})
            rescue
              total=ContentManagerSystem::Term.all(:taxonomy => {:id => params['taxonomy_id']}).length
            end
            
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Retrieve a term
        #
        app.get "/term/:id" do
          
          puts "Getting term"
          
          term = ContentManagerSystem::Term.get(params['id'])
          
          puts "term loaded : #{term}"
          
          status 200
          content_type :json
          term.to_json
        
        end
        
        #
        # Create a new term
        #
        app.post "/term" do
        
          puts "Creating term"
          
          request.body.rewind
          term_request = JSON.parse(URI.unescape(request.body.read))
          
          # Creates the new content
          term = ContentManagerSystem::Term.new(term_request)
          term.save
          
          puts "created term : #{term.to_json}"
          
          # Return          
          status 200
          content_type :json
          term.to_json          
        
        end
        
        #
        # Updates a term
        #
        app.put "/term" do
        
          puts "Updating term"
        
          request.body.rewind
          term_request = JSON.parse(URI.unescape(request.body.read))
          
          # Updates the term
          term = ContentManagerSystem::Term.get(term_request['id'])
          term.attributes=(term_request)
          term.save
          
          puts "updated term : #{term}"
                   
          # Return          
          status 200
          content_type :json
          term.to_json
        
        
        end
        
        # Deletes a content
        app.delete "/term" do
        
        end
      
      end
    
    end #TermManagement
  end #YSD
end #Sinatra