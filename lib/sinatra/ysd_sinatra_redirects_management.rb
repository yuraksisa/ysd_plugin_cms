module Sinatra
  module YitoExtension
    module RedirectManagement

      def self.registered(app)

        #
        # Factor definition page
        #
        app.get '/admin/cms/redirects/?*', :allowed_usergroups => ['editor','staff','webmaster'] do 

          locals = {:redirects_page_size => 20}
          load_em_page :redirects_management, nil, false, :locals => locals

        end

      end

    end
  end
end