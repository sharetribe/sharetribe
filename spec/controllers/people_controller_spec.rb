require 'spec_helper'

describe PeopleController, type: :controller do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
  end

  describe "#check_email_availability" do
    before(:each) do
      @request.host = "#{FactoryGirl.create(:community).ident}.lvh.me"
    end

    it "should return available if email not in use" do
      get :check_email_availability,  {:person => {:email => "totally_random_email_not_in_use@example.com"}, :format => :json}
      expect(response.body).to eq("true")
    end
  end

  describe "#check_email_availability" do
    before(:each) do
      @request.host = "#{FactoryGirl.create(:community).ident}.lvh.me"
    end

    it "should return unavailable if email is in use" do
      person = FactoryGirl.create(:person, :emails => [ FactoryGirl.create(:email, :address => "test@example.com")])

      get :check_email_availability,  {:person => {:email_attributes => {:address => "test@example.com"} }, :format => :json}
      expect(response.body).to eq("false")

      Email.create(:person_id => person.id, :address => "test2@example.com")
      get :check_email_availability,  {:person => {:email_attributes => {:address => "test2@example.com"} }, :format => :json}
      expect(response.body).to eq("false")
    end

    it "should return NOT available for user's own adress" do
      person = FactoryGirl.create(:person)
      sign_in person

      Email.create(:person_id => person.id, :address => "test2@example.com")
      get :check_email_availability,  {:person => {:email_attributes => {:address => "test2@example.com"} }, :format => :json}
      expect(response.body).to eq("false")
    end

  end

  describe "#check_email_availability_and_validity" do
    before(:each) do
      @request.host = "#{FactoryGirl.create(:community).ident}.lvh.me"
    end

    it "should return available for user's own adress" do
      person = FactoryGirl.create(:person)
      sign_in person

      Email.create(:person_id => person.id, :address => "test2@example.com")
      get :check_email_availability_and_validity,  {:person => {:email => "test2@example.com"}, :format => :json}
      expect(response.body).to eq("true")
    end
  end

  describe "#create" do

    it "creates a person" do
      @request.host = "#{FactoryGirl.create(:community).ident}.lvh.me"
      person_count = Person.count
      username = generate_random_username
      post :create, {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}, :community => "test"}
      expect(Person.find_by_username(username)).not_to be_nil
      expect(Person.count).to eq(person_count + 1)
    end

    it "doesn't create a person for community if email is not allowed" do

      username = generate_random_username
      community = FactoryGirl.build(:community, :allowed_emails => "@examplecompany.co")
      community.save
      @request.host = "#{community.ident}.lvh.me"

      post :create, {:person => {:username => username, :password => "test", :email => "#{username}@example.com", :given_name => "", :family_name => ""}}

      expect(Person.find_by_username(username)).to be_nil
      expect(flash[:error].to_s).to include("This email is not allowed")
    end
  end

  describe "#destroy" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.ident}.lvh.me"
      @person = FactoryGirl.create(:person)
      @community.members << @person
      @id = @person.id
      expect(Person.find_by_id(@id)).not_to be_nil
    end

    it "deletes the person" do
      sign_in_for_spec(@person)

      delete :destroy, {:person_id => @id}
      expect(response.status).to eq(302)

      expect(Person.find_by_id(@id).deleted?).to eql(true)
    end

    it "doesn't delete if not logged in as target person" do
      b = FactoryGirl.create(:person)
      @community.members << b
      sign_in_for_spec(b)

      delete :destroy, {:person_id => @id}
      expect(response.status).to eq(302)

      expect(Person.find_by_id(@id)).not_to be_nil
    end

  end

end
