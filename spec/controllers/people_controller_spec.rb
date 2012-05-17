require 'spec_helper'

describe PeopleController do
  fixtures :communities
  fixtures :people
  
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
  end
  
  # First general tests and then ASI / No-ASI specific ones
  
  describe "#check_email_availability" do
    it "should return available if email not in use" do
      @request.host = "test.lvh.me"
      get :check_email_availability,  {:person => {:email => "totally_random_email_not_in_use@example.com"}, :format => :json}
      response.body.should == "true"
    end
    
    if not use_asi?
      
      it "should return unavailable if email is in use" do
        @request.host = "test.lvh.me"
        person, session = get_test_person_and_session
        person.update_attribute(:email, "test@example.com")


        puts Person.email_available?("test@example.com")
        get :check_email_availability,  {:person => {:email => "test@example.com"}, :format => :json}
        response.body.should == "false"

        Email.create(:person_id => person.id, :address => "test2@example.com")
        get :check_email_availability,  {:person => {:email => "test2@example.com"}, :format => :json}
        response.body.should == "false"  
      end
      
      it "should return available for user's own adress" do
        @request.host = "test.lvh.me"

        person, session = get_test_person_and_session
        sign_in person
      
        person.update_attribute(:email, "test@example.com")
        get :check_email_availability,  {:person => {:email => "test@example.com"}, :format => :json}
        response.body.should == "true"
        
        Email.create(:person_id => person.id, :address => "test2@example.com")
        get :check_email_availability,  {:person => {:email => "test2@example.com"}, :format => :json}
        response.body.should == "true"
      end
      
    end
  end
  
  
  if (use_asi?)
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
  end
  
  if not (use_asi?)
    puts "The tests for person_controller without ASI are not done."
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
end
