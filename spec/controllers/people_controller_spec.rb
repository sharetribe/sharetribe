require 'spec_helper'

describe PeopleController do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
  end

  describe "#check_email_availability" do
    it "should return available if email not in use" do
      @request.host = "test.lvh.me"
      get :check_email_availability,  {:person => {:email => "totally_random_email_not_in_use@example.com"}, :format => :json}
      response.body.should == "true"
    end
  end

  describe "#check_email_availability" do
    it "should return unavailable if email is in use" do
      @request.host = "test.lvh.me"
      person = FactoryGirl.create(:person, :emails => [ FactoryGirl.create(:email, :address => "test@example.com")])

      get :check_email_availability,  {:person => {:email_attributes => {:address => "test@example.com"} }, :format => :json}
      response.body.should == "false"

      Email.create(:person_id => person.id, :address => "test2@example.com")
      get :check_email_availability,  {:person => {:email_attributes => {:address => "test2@example.com"} }, :format => :json}
      response.body.should == "false"
    end

    it "should return NOT available for user's own adress" do
      @request.host = "test.lvh.me"

      person = FactoryGirl.create(:person)
      sign_in person

      Email.create(:person_id => person.id, :address => "test2@example.com")
      get :check_email_availability,  {:person => {:email_attributes => {:address => "test2@example.com"} }, :format => :json}
      response.body.should == "false"
    end

  end

  describe "#check_email_availability_and_validity" do
    it "should return available for user's own adress" do
      @request.host = "test.lvh.me"

      person = FactoryGirl.create(:person)
      sign_in person

      Email.create(:person_id => person.id, :address => "test2@example.com")
      get :check_email_availability_and_validity,  {:person => {:email => "test2@example.com"}, :format => :json}
      response.body.should == "true"
    end
  end

  describe "#update" do
    it "should store the old accepted email as additional email when changing email" do

      # one reason for this is that people can't use one email to create many accounts in email restricted community
      community = FactoryGirl.build(:community, :allowed_emails => "@examplecompany.co")
      @request.host = "#{community.domain}.lvh.me"
      member = FactoryGirl.build(:person, :emails => [ FactoryGirl.build(:email, :address => "one@examplecompany.co")])
      member.communities.push community
      member.save

      person_count = Person.count

      sign_in_for_spec(member)

      request.env["HTTP_REFERER"] = "http://test.host/en/people/#{member.id}"
      put :update, {:person => {:email => "something@el.se"}, :person_id => member.id}

      # remove "signed in" stubs
      request.env['warden'].unstub :authenticate!
      #request.env['warden'].stub(:authenticate!).and_throw(:warden)
      controller.unstub :current_person

      post :create, {:person => {:username => generate_random_username, :password => "test", :email => "one@examplecompany.co", :given_name => "The user who", :family_name => "tries to use taken email"}, :community => community.domain}

      Person.find_by_family_name("tries to use taken email").should be_nil
      Person.count.should == person_count
      flash[:error].to_s.should include("The email you gave is already in use")

    end
  end

  describe "#create" do

    it "creates a person" do
      @request.host = "test.lvh.me"
      person_count = Person.count
      username = generate_random_username
      post :create, {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => "test"}
      Person.find_by_username(username).should_not be_nil
      Person.count.should == person_count + 1
    end

    it "doesn't create a person for community if email is not allowed" do

      username = generate_random_username
      community = FactoryGirl.build(:community, :allowed_emails => "@examplecompany.co")
      community.save
      @request.host = "#{community.domain}.lvh.me"

      post :create, {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => community.domain}

      Person.find_by_username(username).should be_nil
      flash[:error].to_s.should include("This email is not allowed")
    end
  end

  describe "#destroy" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.domain}.lvh.me"
      @person = FactoryGirl.create(:person)
      @community.members << @person
      @id = @person.id
      Person.find_by_id(@id).should_not be_nil

    end

    it "deletes the person" do
      sign_in_for_spec(@person)

      delete :destroy, {:person_id => @id}
      response.status.should == 302

      Person.find_by_id(@id).should be_nil
    end

    it "doesn't delete if not logged in as target person" do
      b = FactoryGirl.create(:person)
      @community.members << b
      sign_in_for_spec(b)

      delete :destroy, {:person_id => @id}
      response.status.should == 302

      Person.find_by_id(@id).should_not be_nil
    end

  end

end
