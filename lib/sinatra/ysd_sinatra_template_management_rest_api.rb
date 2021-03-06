require 'ysd_md_cms' unless defined?ContentManagerSystem::Template
module Sinatra
  module YSD
    #
    # REST API to manage Template
    #
    module TemplateManagementRESTApi

      def self.registered(app)
   
        ['/api/templates','/api/templates/page/:page'].each do |path|
          app.post path, :allowed_usergroups => ['staff','webmaster'] do
            
            query_options = {}
            
            if request.media_type == "application/json"
              request.body.rewind
              search_request = JSON.parse(URI.unescape(request.body.read))
              if search_request.has_key?('search')
                query_options[:conditions] = {:name.like => "%#{search_request['search']}%"}
              end
            end

            page_size = SystemConfiguration::Variable.
              get_value('cms.templates.page_size', 20).to_i 
  
            page = [params[:page].to_i, 1].max  

            data, total = ContentManagerSystem::Template.all_and_count(
              query_options.merge({:order => :name.asc, :offset => (page - 1)  * page_size, :limit => page_size}) )
            
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json

          end
        end   

        #
        # Creates a new template
        #
        app.get '/api/template/:id', :allowed_usergroups => ['staff','webmaster'] do
        
          if template = ContentManagerSystem::Template.get(params[:id])
            status 200
            content_type :json
            template.to_json
          else
            status 404
          end
          
        end
        
        #
        # Creates a new template
        #
        app.post '/api/template', :allowed_usergroups => ['staff','webmaster'] do
        
          template_request = body_as_json(ContentManagerSystem::Template)
          
          created_template = ContentManagerSystem::Template.new(template_request)
          begin
            created_template.save
          rescue DataMapper::SaveFailureError => error
             p "Error saving template #{error} #{created_template.inspect} #{created_template.errors.inspect}"
             raise error 
          end
          status 200
          content_type :json
          created_template.to_json

        end
        
        #
        # Updates a template
        #
        app.put '/api/template', :allowed_usergroups => ['staff','webmaster'] do

          template_request = body_as_json(ContentManagerSystem::Template)
          template_id = template_request.delete(:id)

          if (not template_id.nil?) and (updatable_template = ContentManagerSystem::Template.get(template_id))
            updatable_template.attributes= template_request
            updatable_template.save
            status 200
            content_type :json
            updatable_template.to_json
          else
            created_template = ContentManagerSystem::Template.create(template_request)
            status 200
            content_type :json
            created_template.to_json
          end

        end

        #
        # Updates multiple templates
        #
        app.put "/api/templates", :allowed_usergroups => ['staff','webmaster'] do
      
          request.body.rewind
          templates = JSON.parse(URI.unescape(request.body.read))      
          
          templates.each do |key, value|
            if template = ContentManagerSystem::Template.first({:name => key})
              template.text = value
              template.save
            end         
          end
          
          content_type :json
          true.to_json
      
        end

        #
        # Delete a template
        #
        app.delete '/api/template', :allowed_usergroups => ['staff','webmaster'] do

          template_request = body_as_json(ContentManagerSystem::Template)
          template_id = template_request.delete(:id)

          if (not template_id.nil?) and (removable_template = ContentManagerSystem::Template.get(template_id))
            removable_template.destroy
            status 200
            content_type :json
            true.to_json
          else
            status 404
          end

        end

      end

    end #TemplateManagementRESTApi
  end #YSD
end #Sinatra