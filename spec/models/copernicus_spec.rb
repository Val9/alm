require 'spec_helper'

describe Copernicus do
  let(:copernicus) { FactoryGirl.create(:copernicus) }
  
  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    copernicus.get_data(article).should eq({ :events => [], :event_count => nil })
  end
  
  it "should report that there are no events if the doi has the wrong prefix" do
    article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
    copernicus.get_data(article).should eq({ :events => [], :event_count => nil })
  end
  
  context "use the Copernicus API" do
    it "should report if there are no events and event_count returned by the Copernicus API" do
      article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
      stub = stub_request(:get, "http://#{copernicus.username}:#{copernicus.password}@harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{article.doi}").to_return(:body => File.read(fixture_path + 'copernicus_nil.json'), :status => 200)
      copernicus.get_data(article).should eq({ :events => [], :event_count => nil })
      stub.should have_been_requested
    end
    
    it "should report if there are events and event_count returned by the Copernicus API" do
      article = FactoryGirl.build(:article, :doi => "10.5194/ms-2-175-2011")
      body = File.read(fixture_path + 'copernicus.json')
      stub = stub_request(:get, "http://#{copernicus.username}:#{copernicus.password}@harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{article.doi}").to_return(:body => body, :status => 200)
      response = copernicus.get_data(article)
      response[:event_count].should == 83
      events = response[:events]
      events["counter"].should_not be_nil
      events["counter"]["AbstractViews"].to_i.should == 72
      stub.should have_been_requested
    end
    
    it "should catch authentication errors with the Copernicus API" do
      article = FactoryGirl.build(:article, :doi => "10.5194/ms-2-175-2011")
      stub = stub_request(:get, "http://#{copernicus.username}:#{copernicus.password}@harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{article.doi}").to_return(:body => File.read(fixture_path + 'copernicus_unauthorized.json'), :status => [401, "Unauthorized: You are not authorized to access this resource."])
      copernicus.get_data(article).should be_nil
      stub.should have_been_requested
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Net::HTTPUnauthorized")
      error_message.message.should include("Unauthorized")
      error_message.status.should == 401
      error_message.source_id.should == copernicus.id
    end
    
    it "should catch timeout errors with the Copernicus API" do
      article = FactoryGirl.build(:article, :doi => "10.5194/ms-2-175-2011")
      stub = stub_request(:get, "http://#{copernicus.username}:#{copernicus.password}@harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{article.doi}").to_return(:status => [408, "Request Timeout"])
      copernicus.get_data(article).should be_nil
      stub.should have_been_requested
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Net::HTTPRequestTimeOut")
      error_message.message.should include("Request Timeout")
      error_message.status.should == 408
      error_message.source_id.should == copernicus.id
    end
  end
end