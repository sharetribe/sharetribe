require 'spec_helper'

describe PeopleController do
  fixtures :communities
  
  describe "#create" do
    it "should tell ASI to skip welcome mail if that's in the community's settings" do
      
      PersonConnection.should_receive(:create_person).with(hash_including({:welcome_email => false}), anything()).and_return({"entry" => {"id" => "dfskh3r29wefhsdifh"}})  
      
      @request.host = "test2.lvh.me"
      username = generate_random_username
      post :create, {:person => {:username => "username", :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}}
    end
    
    it "should tell ASI to send welcome mail if that's in the community's settings" do
     
      PersonConnection.should_receive(:create_person).with(hash_including({:welcome_email => true}), anything()).and_return({"entry" => {"id" => "dfskh3r29wefhsdifh"}})  
      
      @request.host = "test.lvh.me"
      username = generate_random_username
      post :create, {:person => {:username => "username", :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}}
    end
    
  end
end
