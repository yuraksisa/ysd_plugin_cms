require 'ysd_md_cms' unless defined?ContentManagerSystem::Template
module Sinatra
  module YSD
    #
    # REST API to manage Template
    #
    module TemplateManagementRESTApi

      def self.registered(app)
   
        ['/templates','/templates/page/:page'].each do |path|
          app.post path do
            
            query_options = {}
            
            if request.media_type == "application/x-www-form-urlencoded"
              if params[:search]
                query_options[:conditions] = {:name.like => "%#{params[:search]}%"} 
              else
                request.body.rewind
                search_text=request.body.read
                query_options[:conditions] = {:name.like => "%#{search_text}%"} 
              end
            end

            page_size = SystemConfiguration::Variable.
              get_value('cms.templates.page_size', 20).to_i 
  
            page = [params[:page].to_i, 1].max  

            data, total = ContentManagerSystem::Template.all_and_count(
              query_options.merge({:offset => (page - 1)  * page_size, :limit => page_size}) )
            
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json

          end
        end   
        
        #
        # Creates a new template
        #
        app.post '/template' do
        
          template_request = body_as_json(ContentManagerSystem::Template)
          created_template = ContentManagerSystem::Template.create(template_request)

          status 200
          content_type :json
          created_template.to_json

        end
        
        #
        # Updates a template
        #
        app.put '/template' do

          template_request = body_as_json(ContentManagerSystem::Template)
          template_id = template_request.delete(:id)

          if (not template_id.nil?) and (updatable_template = ContentManagerSystem::Template.get(template_id))
            updatable_template.attributes= template_request
            updatable_template.save
            status 200
            content_type :json
            updatable_template.to_json
          else
            status 404
          end

        end

        #
        # Delete a template
        #
        app.delete '/template' do

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