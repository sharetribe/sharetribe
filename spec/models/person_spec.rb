require 'spec_helper'

describe Person do
  
  # This method could be moved to a separate helper
  def get_test_person_and_session(username="kassi_testperson1")  
    #frist try loggin in to ASI
    begin
      session = Session.create({:username => username, :password => "testi" })
      #try to find in kassi database
      test_person = Person.find(session.person_id)

    rescue RestClient::Request::Unauthorized => e
      #if not found, create completely new person
      session = Session.create
      test_person = Person.create({ :username => username, 
                      :password => "testi", 
                      :email => "#{username}@example.com"},
                       session.headers["Cookie"])
                       
    rescue ActiveRecord::RecordNotFound  => e
      test_person = Person.add_to_kassi_db(session.person_id)
    end
    return [test_person, session]
  end
  
  
  before(:all) do
    #These will be created only once for the whole example group
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
  end
  
  before(:each) do
    # here some people could be initialized
  end
  
  describe "#create" do
    it "should create a person in ASI and Kassi DB" do
      pending "add some code to test Person.create"
    end
    
    it "should not store anything to Kassi DB if ASI request failed" do
      pending "add some code to test Person.create"
    end
  end

  describe "#update_attributes" do
    it "should update attributes to ASI"
  end
  
  describe "#update_avatar" do
    it "should update avatar image to ASI"
  end
  
  describe "#create_listing" do
    it "creates a new listing with the submitted attributes" do
      listing = @test_person.create_listing :title => "Test"
      listing.title.should == "Test"
      @test_person.listings.should == [listing]
    end
  end
  
  describe "#name and other name getters" do
    before(:each) do
      @test_person.update_attributes({'given_name' => "Ripa", 'family_name' => "Riuska"}, @cookie)
    end
    
    it "returns the name of the user" do
      @test_person.name.should_not be_blank
      @test_person.name.should == "Ripa Riuska"
    end
    
    it "returns the given or the last name of the user" do
      @test_person.given_name(@cookie).should == "Ripa"
      @test_person.family_name(@cookie).should == "Riuska"
    end
  end
  
  describe "email functions" do
    before(:each) do
      @test_person.set_email("testing_one@example.com", @cookie)
    end
    
    it "should return the email correctly" do
      @test_person.email(@cookie).should == "testing_one@example.com"
    end
    
    it "should change email" do
      @test_person.set_email("testing_two@example.com", @cookie)
      @test_person.email(@cookie).should == "testing_two@example.com"
    end
  end
  
  describe "#add_to_kassi_db" do

    it "should add a person to kassi db" do
      p = Person.add_to_kassi_db("testingID")
      p.should_not be_nil
      p.class.should == Person
      Person.find_by_id("testingID").should_not be_nil
      p.destroy
    end
    
  end
end