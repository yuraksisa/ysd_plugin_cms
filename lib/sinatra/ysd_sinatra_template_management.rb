module Sinatra
  module YSD
  	#
  	# Sinatra extension to manage templates
  	#
  	module TemplateManagement
      def self.registered(app)
        
        app.get '/admin/templates' do

          load_page :template_management, 
            :locals => {:template_page_size => 20}

        end

      end
  	end
  end
end