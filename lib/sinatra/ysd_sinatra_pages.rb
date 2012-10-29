module Sinatra
  module YSD
    module Pages
   
      def self.registered(app)
                  
        # Load a page from the views directory (without layout)
        #
        app.get '/page/:page/nolayout' do
          load_page params[:page], :layout => false
        end
        
        # Load a page from the views directory (with layout)
        #
        app.get '/page/:page' do
          load_page params[:page]
        end
      
      end 
    
    end
  end
end