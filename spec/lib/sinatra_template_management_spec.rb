require 'spec_helper'
require 'rack/test'

describe Sinatra::YSD::TemplateManagement do 
  include Rack::Test::Methods
  
  def app
    TestingSinatraApp.class_eval do
      register Sinatra::YSD::TemplateManagement
    end
    TestingSinatraApp
  end

  describe '/admin/cms/templates' do
   
   before :each do
     app.any_instance.should_receive(:load_page).
       with(:template_management, 
       :locals => {:template_page_size => 20}).and_return('Hello World!')
   end

   subject do 
     get '/admin/cms/templates'
     last_response       
   end

   its(:status) { should == 200 }

  end	

end