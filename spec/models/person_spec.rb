require 'spec_helper'

describe Person do  
  
  before(:all) do
    #These will be created only once for the whole example group
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
  end
  
  after(:all) do
    # For some reason this logging out at the end causes some examples to fail
    #@session.destroy
  end
  
  it "should be valid" do
    @test_person.should_not be_nil
    @test_person.should be_valid
  end
  
  it "should have an id other than 0" do
    @test_person.id.should_not == 0
    # "Test_person.id is 0, possible reason is INT type for id in test DB."
  end
  
  describe "#create" do
    it "should create a person in ASI and Kassi DB" do
      username = generate_random_username
      p = Person.create({:username => username, 
        :password => "testi", 
        :email => "#{username}@example.com",
        "given_name" => "Tero",
        "family_name" => "Turari"}, Session.kassi_cookie)
      Person.find(p.id).should_not be_nil
      p.username.should == username
    end
    
    it "should not store anything to Kassi DB if ASI request failed" do
      username = generate_random_username
      lambda {
        p = nil
        lambda {
          p = Person.create({:username => username, 
            :password => "testi", 
            :email => "invalid-email",
            "given_name" => "Tero",
            "family_name" => "Turari"}, Session.kassi_cookie)
        }.should raise_error(RestClient::BadRequest)
        p.should be_nil
      }.should_not change{Person.count}
    end
  end

  describe "#update_attributes" do
    it "should update attributes to ASI" do
      @test_person.update_attributes({'given_name' => "Totti", 
        'family_name' => "Tester", 
        'street_address' => "salainen",
        'phone_number' => "050-55555555"}, @cookie)
      @test_person.street_address.should == "salainen"
      @test_person.phone_number.should == "050-55555555"
    end
  end
  
  describe "#create_listing" do
    it "creates a new listing with the submitted attributes" do
      listing = @test_person.create_listing :title => "Test"
      listing.title.should == "Test"
      @test_person.listings.should == [listing]
    end
  end
  
  describe "name getters" do
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
    
    describe "#given_name" do
      
      it "should return the given name" do
        @test_person.given_name.should == "Ripa"
      end
      
      it "should return blank if given name is blank" do
        @test_person.update_attributes({'given_name' => "", 'family_name' => ""}, @cookie)
        @test_person.given_name.should == ""
      end
      
    end
    
    describe "#given_name_or_username" do

      it "should return the given name if it exists" do
        @test_person.given_name_or_username.should == "Ripa"
      end

      it "should return username if given name is blank" do
        @test_person.update_attributes({'given_name' => "", 'family_name' => ""}, @cookie)
        @test_person.given_name_or_username.should == @test_person.username
      end

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