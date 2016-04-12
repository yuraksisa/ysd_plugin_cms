module Sinatra
  module YitoExtension
    module PagesSupportManagement

      def self.registered(app)

        #
        # Factor definition page
        #
        app.get '/admin/cms/pages-support/?*', :allowed_usergroups => ['editor','staff'] do 

          locals = {:pages_support_page_size => 20}
          load_em_page :pages_support_management, nil, false, :locals => locals

        end

      end

    end
  end
end