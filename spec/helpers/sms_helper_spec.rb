require 'spec_helper'

describe SmsHelper do
  if APP_CONFIG.use_sms
    describe "#parse" do
      it "splits a ridesharing message to valid details" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"ride offer tkk taik 14:00", "calendar"=>"2010-10-10T08:03:04+00:00"}
        details = SmsHelper.parse(message)
        details.should_not be_nil
        details[:phone_number].should == message["msisdn"]
        details[:listing_type].should == "offer"
        details[:category].should == "rideshare"
        details[:origin].should == "tkk"
        details[:destination].should == "taik"
      end
    
      it "accpets a rideshare messsage also with other languages" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"kyyti pyyntö otaniemi rautatieasema,helsinki 14:10", "calendar"=>"2010-10-10T08:03:04+00:00"}
        details = SmsHelper.parse(message)
        details.should_not be_nil
        details[:phone_number].should == message["msisdn"]
        details[:listing_type].should == "request"
        details[:category].should == "rideshare"
        details[:origin].should == "otaniemi"
        details[:destination].should == "rautatieasema,helsinki"
        [Time.zone.parse("14:10").to_datetime, (Time.zone.parse("14:10").to_datetime + 1.days)].should include(details[:valid_until])
      end
      
      it "puts the time to 'after one hour' if time omitted" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"ride o tkk city", "calendar"=>"2010-10-10T08:03:04+00:00"}
        details = SmsHelper.parse(message)
        details.should_not be_nil
        details[:phone_number].should == message["msisdn"]
        details[:listing_type].should == "offer"
        details[:category].should == "rideshare"
        details[:origin].should == "tkk"
        details[:destination].should == "city"
        details[:valid_until].should < 1.01.hour.from_now
        details[:valid_until].should > 0.99.hour.from_now
      end
      
      it "accepts short froms for request and offer keywords" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"ride o tkk city 14:00", "calendar"=>"2010-10-10T08:03:04+00:00"}
        details = SmsHelper.parse(message)
        details.should_not be_nil
        details[:phone_number].should == message["msisdn"]
        details[:listing_type].should == "offer"
        details[:category].should == "rideshare"
        details[:origin].should == "tkk"
        details[:destination].should == "city"
      end
      
      it "splits correctly and defaults to rideshare, if category omitted" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"r home city", "calendar"=>"2010-10-10T08:03:04+00:00"}
        details = SmsHelper.parse(message)
        details.should_not be_nil
        details[:phone_number].should == message["msisdn"]
        details[:listing_type].should == "request"
        details[:category].should == "rideshare"
        details[:origin].should == "home"
        details[:destination].should == "city"
        details[:valid_until].should < 1.01.hour.from_now
        details[:valid_until].should > 0.99.hour.from_now
      end
      
      it "parses short formed messages also in other languages" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>" p otski steissi", "calendar"=>"2010-10-10T08:03:04+00:00"}
        details = SmsHelper.parse(message)
        details.should_not be_nil
        details[:phone_number].should == message["msisdn"]
        details[:listing_type].should == "request"
        details[:category].should == "rideshare"
        details[:origin].should == "otski"
        details[:destination].should == "steissi"
        details[:valid_until].should < 1.01.hour.from_now
        details[:valid_until].should > 0.99.hour.from_now
      end
      
      it "picks description even if time is omitted" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"r home city I'd like to get home soon!", "calendar"=>"2010-10-10T08:03:04+00:00"}
        details = SmsHelper.parse(message)
        details.should_not be_nil
        details[:phone_number].should == message["msisdn"]
        details[:listing_type].should == "request"
        details[:category].should == "rideshare"
        details[:origin].should == "home"
        details[:destination].should == "city"
        details[:description].should == "I'd like to get home soon!"
        details[:valid_until].should < 1.01.hour.from_now
        details[:valid_until].should > 0.99.hour.from_now
      end
    
      it "splits a payment message to valid details" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"pay Simo 8,50e ", "calendar"=>"2010-10-10T08:03:04+00:00"}
        details = SmsHelper.parse(message)
        details.should_not be_nil
        details[:phone_number].should == message["msisdn"]
        details[:category].should == "pay"
        details[:receiver].should == "Simo"
        details[:amount].should == "8.50"
      
      end
    
      it "does case insensitive parsing" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"Maksa simo 5,50", "calendar"=>"2010-10-10T08:03:04+00:00"}
        details = SmsHelper.parse(message)
        details.should_not be_nil
        details[:phone_number].should == message["msisdn"]
        details[:category].should == "pay"
        details[:receiver].should == "simo"
        details[:amount].should == "5.50"
      end
    
      it "handles malformated messages" do
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"ride london manchester", "calendar"=>"2010-10-10T08:03:04+00:00"}
        lambda {
          details = SmsHelper.parse(message)
        }.should raise_error(SmsController::SmsParseError)
        
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"london manchester", "calendar"=>"2010-10-10T08:03:04+00:00"}
        lambda {
          details = SmsHelper.parse(message)
        }.should raise_error(SmsController::SmsParseError)
        
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"oiffer london manchester", "calendar"=>"2010-10-10T08:03:04+00:00"}
        lambda {
          details = SmsHelper.parse(message)
        }.should raise_error(SmsController::SmsParseError)
        
        message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"offer london", "calendar"=>"2010-10-10T08:03:04+00:00"}
        lambda {
          details = SmsHelper.parse(message)
        }.should raise_error(SmsController::SmsParseError)
        
        
      end
    
    end
  
    describe "#send" do
      it "should send the given text as sms to given number" do
          RestClient.should_receive(:post).with(/http:\/\/api.medialab.sonera.fi\/iw\/rest\/messaging\/sms/, 
            /"address" : "358501234567", "message" : "running tests of Kassi"/, 
            {:content_type => 'application/json'}).and_return(true)
          SmsHelper.send("running tests of Kassi", "358501234567")
        end
    end
  
    describe "#get_messages" do
      it "should return an array of hashes containing the messages" do
      
        RestClient.should_receive(:get).and_return("<userKey>test_key<\/userKey>", '{"receiver" : { "messages" : [] } }')
      
        messages = SmsHelper.get_messages
        messages.should be_instance_of(Array)
      end
    end
  
    describe "#delete_messages" do
      it "should delete the messages specidied in params from the inbox" do
        RestClient.should_receive(:delete).with(/http:\/\/api.medialab.sonera.fi\/iw\/rest\/receive\/#{APP_CONFIG.sms_username}\/#{APP_CONFIG.sms_receiver_id}\/.*example_id.*/,  {:Accept => 'application/json'}).and_return(true)
        SmsHelper.delete_messages(["example_id"])
      end
    end
  
    describe "#all_translations" do
      it "should retun all available translations for given key. Joined by |" do
        translations = SmsHelper.all_translations("sms.offer")
        translations.should include(I18n.t("sms.offer", :fi)) 
        translations.should include(I18n.t("sms.offer", :en))
        translations.should include("|")
      
      end
    end
  end
end