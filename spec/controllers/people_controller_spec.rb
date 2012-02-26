require 'spec_helper'

describe PeopleController do
  fixtures :communities
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
  end
  
  context "When ASI is used as the storage for Person data" do
    
    
    
    describe "#create" do
      it "should tell ASI to skip welcome mail if that's in the community's settings" do
      
        PersonConnection.should_receive(:create_person).with(hash_including({:welcome_email => false}), anything()).and_return({"entry" => {"id" => "dfskh3r29wefhsdifh"}})  
        PersonConnection.should_receive(:put_attributes).and_return({"entry" => {}})  
      
        @request.host = "login.lvh.me"
        username = generate_random_username
        post :create, {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => "test2"}
      end
    
      it "should tell ASI to send welcome mail if that's in the community's settings" do
     
        PersonConnection.should_receive(:create_person).with(hash_including({:welcome_email => true}), anything()).and_return({"entry" => {"id" => "dfskh3r29wefhsdifh"}})  
        PersonConnection.should_receive(:put_attributes).and_return({"entry" => {}})  
      
        @request.host = "login.lvh.me"
        username = generate_random_username
        post :create, {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => "test"}
      end
    
      it "redirects back to original community's domain" do
        PersonConnection.should_receive(:create_person).and_return({"entry" => {"id" => "dfskh3r29wefhsdifh"}})  
        PersonConnection.should_receive(:put_attributes).and_return({"entry" => {}})  
      
        @request.host = "login.lvh.me"
        username = generate_random_username
        post :create, {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => "test"}
        response.should redirect_to "http://test.lvh.me/?locale=en"
      end
    end
  end
  
  
  # context "When ASI is not used but Person is stored only in Kassi DB" do
  #  
  #   before(:all) do
  #       reload_person_set_ASI_usage_to(false)
  #   end
  #     
  #   after(:all) do
  #       reload_person_set_ASI_usage_to(true)
  #   end
  #   
  #   describe "#create" do
  #     
  #     it "creates a person" do
  #       username = generate_random_username
  #       Person.all.each {|p| puts p.username}
  #       puts ""
  #       post :create, {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => "test"}
  #       Person.all.each {|p| puts p.username}
  #       response.should redirect_to(root_path)
  #       puts response
  #       Person.find_by_username(username).should_not be_nil  
  #     end
  #   
  #     it "redirects back to original community's domain" do   
  #       @request.host = "login.lvh.me"
  #       username = generate_random_username
  #       post :create, {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => "test"}
  #       response.should redirect_to "http://test.lvh.me/?locale=en"
  #     end
  #   end
  # end
end
