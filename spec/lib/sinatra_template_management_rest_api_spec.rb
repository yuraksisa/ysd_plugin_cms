require 'spec_helper'
require 'rack/test'
require 'ysd_md_cms'
require 'json'

describe Sinatra::YSD::TemplateManagementRESTApi do
  include Rack::Test::Methods

  let(:template) do
  	 {:name => 'variable',
      :text => '<p>Hello</p>'}
  end
  
  def app
    TestingSinatraApp.class_eval do
      register Sinatra::YSD::TemplateManagementRESTApi
    end
    TestingSinatraApp
  end

  describe "POST /templates" do
    
    before :each do
      SystemConfiguration::Variable.should_receive(:get_value).
          with('cms.templates.page_size', 20).
          and_return(10) 
    end

    context "no pagination and no query" do

      before :each do
        ContentManagerSystem::Template.should_receive(:all_and_count).
          with(hash_including({:offset => 0, :limit => 10})).
          and_return([[ContentManagerSystem::Template.new(template)], 1])
      end

      subject do
        post '/templates', {}
        last_response
      end

      its(:status) { should == 200 } 
      its(:header) { should have_key 'Content-Type' }
      it { subject.header['Content-Type'].should match(/application\/json/) }
      its(:body) { should == {:data => [ContentManagerSystem::Template.new(template)], :summary => {:total => 1}}.to_json }
    
    end

    context "pagination" do

      before :each do
        ContentManagerSystem::Template.should_receive(:all_and_count).
          with(hash_including({:offset => 10, :limit => 10})).
          and_return([[ContentManagerSystem::Template.new(template)], 1])
      end

      subject do
        post '/templates/page/2', {}
        last_response
      end

      its(:status) { should == 200 } 
      its(:header) { should have_key 'Content-Type' }
      it { subject.header['Content-Type'].should match(/application\/json/) }
      its(:body) { should == {:data => [ContentManagerSystem::Template.new(template)], :summary => {:total => 1}}.to_json }

    end

    context "pagination and query" do

      before :each do
        ContentManagerSystem::Template.should_receive(:all_and_count).
          with(hash_including(:offset => 10, :limit => 10)).
          and_return([[ContentManagerSystem::Template.new(template)], 1])
      end

      subject do 
        post '/templates/page/2', {:search => 'text'}
        last_response
      end
      
      its(:status) {should == 200}
      its(:header) {should have_key 'Content-Type'}
      it { subject.header['Content-Type'].should match(/application\/json/) }
      its(:body) { should == {:data => [ContentManagerSystem::Template.new(template)], :summary => {:total => 1}}.to_json }

    end

  end

  describe "POST /template" do
    
    context "new template creation ok" do
      
      before :each do
        ContentManagerSystem::Template.should_receive(:create).
          with(template).
          and_return(ContentManagerSystem::Template.new(template))
      end

      subject do 
        post '/template', template.to_json
        last_response
      end

      its(:status) { should == 200 }
      its(:header) { should have_key 'Content-Type'}
      it { subject.header['Content-Type'].should match(/application\/json/) }
        its(:body) { should == ContentManagerSystem::Template.new(template).to_json}
    
    end

  end

  describe "PUT /template" do
  
    context "updating existing template" do

      before :each do
        updatable_template = ContentManagerSystem::Template.new(template)
        ContentManagerSystem::Template.should_receive(:get).
          with(1).
          and_return(updatable_template)
        updatable_template.should_receive(:save).
          and_return(true)
      end

      subject do 
        put '/template', template.merge(:id => 1).to_json
        last_response
      end
   
      its(:status) { should == 200 }
      its(:header) { should have_key 'Content-Type'}
      it { subject.header['Content-Type'].should match(/application\/json/) }

    end

    context "updating non existing template" do

      before :each do
        ContentManagerSystem::Template.should_receive(:get).
          with(1).
          and_return(nil)
      end

      subject do 
        put '/template', template.merge(:id => 1).to_json
        last_response
      end
   
      its(:status) { should == 404 }

    end
   
  end

  describe "DELETE /template" do
  
    context "deleting existing template" do

      before :each do
        removable_template = ContentManagerSystem::Template.new(template)
        ContentManagerSystem::Template.should_receive(:get).
          with(1).
          and_return(removable_template)
        removable_template.should_receive(:destroy).
          and_return(true)
      end

      subject do 
        delete '/template', template.merge(:id => 1).to_json
        last_response
      end
   
      its(:status) { should == 200 }
      its(:header) { should have_key 'Content-Type'}
      it { subject.header['Content-Type'].should match(/application\/json/) }
      its(:body) { should == true.to_json}

    end

    context "deleting non existing template" do

      before :each do
        ContentManagerSystem::Template.should_receive(:get).
          with(1).
          and_return(nil)
      end

      subject do 
        delete '/template', template.merge(:id => 1).to_json
        last_response
      end
   
      its(:status) { should == 404 }

    end


  end

end