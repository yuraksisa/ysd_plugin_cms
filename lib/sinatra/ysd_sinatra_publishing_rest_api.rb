require 'ysd_md_publishing_workflow'
module Sinatra
  module YSD
    module PublishingRESTApi

      def self.registered(app)
        
        #
        # Retrieve the configured workflows
        #
        app.get '/workflows' do

          data=ContentManagerSystem::PublishingWorkFlow.all
          
          content_type :json
          data.to_json
        end

        #
        # Retrieve the states
        #
        app.get '/publishing/states' do

          data=ContentManagerSystem::PublishingState.all
          
          content_type :json
          data.to_json
        end

        #
        # Retrieve the actions
        #
        app.get '/publishing/actions' do

          data= ContentManagerSystem::PublishingAction.all

          content_type :json
          data.to_json
        end

      end

    end #PublishingWorkFlowRESTApi
  end #YSD
end #Sinatra