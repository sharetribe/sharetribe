require 'spec_helper'

describe Person do
  if (use_asi?)
    context "When ASI is used as the storage for Person data" do
    
      before(:all) do
        #reload_person_set_ASI_usage_to(true)
      
        #These will be created only once for the whole example group
        @test_person, @session = get_test_person_and_session
        @cookie = @session.cookie
      end
  
      after(:all) do
        #reload_person_set_ASI_usage_to(false)
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
        it "should create a person in ASI and Sharetribe DB" do
          username = generate_random_username
          p = Person.create({:username => username, 
            :password => "testi", 
            :email => "#{username}@example.com",
            "given_name" => "Tero",
            "family_name" => "Turari"}, Session.kassi_cookie)
          Person.find(p.id).should_not be_nil
          p.username.should == username
        end
    
        it "should not store anything to Sharetribe DB if ASI request failed" do
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
  end
    
  
  if not (use_asi?)
    context "When ASI is not used but Person is stored only in Sharetribe DB" do
       before(:all) do
          #reload_person_set_ASI_usage_to(false)
        
          #These will be created only once for the whole example group
          @test_person, @session = get_test_person_and_session
        
        end
      
        after(:all) do
          #reload_person_set_ASI_usage_to(true)
        end

        it "should be valid" do
          @test_person.class.should == Person
          @test_person.should_not be_nil
          @test_person.should be_valid
        end

        it "should have an id other than 0" do
          @test_person.id.should_not == 0
          # "Test_person.id is 0, possible reason is INT type for id in test DB."
        end

        describe "#create" do
          it "should create a person in Sharetribe DB" do
            username = generate_random_username
            p = Person.create!({:username => username, 
              :password => "testi", 
              :email => "#{username}@example.com",
              "given_name" => "Tero",
              "family_name" => "Turari",
              "confirmed_at" => Time.now})
            Person.find(p.id).should_not be_nil
            p.username.should == username
          end

          it "should not store anything to Sharetribe DB if creation failed for invalid data" do
            username = generate_random_username
            lambda {
              p = nil
              lambda {
                p = Person.create!({:username => username, 
                  :password => "testi", 
                  :email => "invalid-email",
                  "given_name" => "Tero",
                  "family_name" => "Turari"})
              }.should raise_error(ActiveRecord::RecordInvalid)
              p.should be_nil
            }.should_not change{Person.count}
          end
        end

        describe "#update_attributes" do
          it "should update the attributes" do
            @test_person.update_attributes({'given_name' => "Totti", 
              'family_name' => "Tester", 
              'phone_number' => "050-55555555"}, @cookie)
            @test_person.family_name.should == "Tester"
            @test_person.phone_number.should == "050-55555555"
          end
        end

        describe "#create_listing" do
          it "creates a new listing with the submitted attributes" do
            listing = @test_person.create_listing :title => "Test"
            listing.title.should == "Test"
            @test_person.listings.last.should == listing
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
            @test_person.given_name.should == "Ripa"
            @test_person.family_name.should == "Riuska"
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
          
          describe "devise valid_password?" do
            it "Test that the hashing works. (makes more sense to test this if ASI digest is used)" do
              Factory(:person).valid_password?('testi').should be_true
              Factory(:person).valid_password?('something_else').should_not be_true
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
        
        describe "#delete" do
          it "should delete also related conversations and testimonials" do
            conv = FactoryGirl.create(:conversation)
            conv.participants << @test_person
            conv_id = conv.id
            Conversation.find_by_id(conv_id).should_not be_nil
            @test_person.conversations.should include(conv)
            
            tes = FactoryGirl.create(:testimonial, :author => @test_person)
            tes_id = tes.id
            Testimonial.find_by_id(tes_id).should_not be_nil
            
            @test_person.destroy
            
            # check that related stuff was removed too
            Conversation.find_by_id(conv_id).should be_nil
            Testimonial.find_by_id(tes_id).should be_nil
            
          end
        end

    end
  end
end