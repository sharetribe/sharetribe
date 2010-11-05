require 'spec_helper'

describe SmsHelper do
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
    
    it "splits a payment message to valid details" do
      message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"pay Simo 8,50e ", "calendar"=>"2010-10-10T08:03:04+00:00"}
      details = SmsHelper.parse(message)
      details.should_not be_nil
      details[:phone_number].should == message["msisdn"]
      details[:category].should == "pay"
      details[:receiver].should == "Simo"
      details[:amount].should == "8.50"
      
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