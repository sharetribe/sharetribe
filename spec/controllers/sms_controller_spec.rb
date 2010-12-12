require 'spec_helper'

describe SmsController do
  fixtures :people
  
  def kassi_receives_message(message, sender_phone = "358501234567", sender_id = people(:one).id)
    message = SmsHelper.parse({"message" => message, "msisdn" => sender_phone, "@id" => "test_id"})
    Person.should_receive(:search_by_phone_number).with(sender_phone).and_return(sender_id.nil? ? nil : {"id" => sender_id})
    SmsHelper.should_receive(:get_messages).and_return([message])
    SmsHelper.should_receive(:delete_messages).and_return(true)
    get :message_arrived
  end 
  
  if APP_CONFIG.use_sms
    describe "receiving sms" do
      it "should check the incoming message queue when sms callback function is called." do
        SmsHelper.should_receive(:get_messages).and_return([])
        get :message_arrived
      end
    
      it "creates a new listing, when the sms requires that" do
      
        # message = SmsHelper.parse({"message" => "ride offer tkk taik 14:00 places for 3 people", "msisdn" => "358501234567", "@id" => "test_id"})
        # Person.should_receive(:search_by_phone_number).with("358501234567").and_return({"id" => people(:one).id})
        # SmsHelper.should_receive(:get_messages).and_return([message])
        # SmsHelper.should_receive(:delete_messages).and_return(true)
        # get :message_arrived 
        kassi_receives_message("ride offer tkk taik 14:00 places for 3 people")
        
        listing = assigns["listing"]
        listing.author_id.should == people(:one).id
        listing.category.should == "rideshare"
        listing.listing_type.should == "offer"
        listing.title.should == "tkk - taik"
        listing.description.should == "places for 3 people"
        listing.origin.should == "tkk"
        listing.destination.should == "taik"
        time =  Time.zone.parse("14:00").to_datetime
        if time < DateTime.now && time > 1.days.ago
          time += 1.days
        end
        listing.valid_until.should == (time)
      end
    
      it "replies with ok message, when a payment request is made" do
        # message = SmsHelper.parse({"message" => "pay george 3e", "msisdn" => "358501234567", "@id" => "test_id"})
        # Person.should_receive(:search_by_phone_number).with("358501234567").and_return({"id" => people(:one).id})
        # SmsHelper.should_receive(:get_messages).and_return([message])
        # SmsHelper.should_receive(:delete_messages).and_return(true)
        # get :message_arrived
        kassi_receives_message("pay george 3e")
        response.body.should include("delivered")
        response.body.should include("3 euros")
        response.body.should include("george")
        response.body.should include("3.15 euros in your phone bill")
      end
      
      it "replies with instructive help, when malformed sms is received." do
        response_matcher =  /could not understand/i
        
        lambda {
          kassi_receives_message("ride offering something")
        }.should raise_error(SmsController::SmsParseError, response_matcher)
        
        lambda {
          kassi_receives_message("asdasdasdasdasdasd")
        }.should raise_error(SmsController::SmsParseError, response_matcher)
        
        lambda {
          kassi_receives_message("ride request place")
        }.should raise_error(SmsController::SmsParseError, response_matcher)
        
      end
      
      it "replies with instructive help, when sender's phone number is not stored" do
        response = kassi_receives_message("ride offer tkk taik 14:00", "358504545454", nil)
        response.body.should =~ /make sure.*phone number is stored in /i
      end
      
      it "replies with instructive help, when sender is not in Kassi database yet." do
        
        response = kassi_receives_message("ride offer tkk taik 14:00", "358504545454", "id_that_does_not_exist_in_kassi_db")
        response.body.should =~ /log in.*Kassi.*before/
      end
      
    end
  end
end
