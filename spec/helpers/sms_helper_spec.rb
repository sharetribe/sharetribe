require 'spec_helper'

describe SmsHelper do
  describe "#parse" do
    it "split a message to valid details" do
      message = {"@id"=>"3907911", "msisdn"=>358501234567, "message"=>"ride offer tkk taik 14:00", "calendar"=>"2010-10-10T08:03:04+00:00"}
      details = SmsHelper.parse(message)
      #puts details.to_yaml
      details.should_not be_nil
      details[:phone_number].should == message["msisdn"]
      details[:listing_type].should == "offer"
      details[:category].should == "rideshare"
      details[:origin].should == "tkk"
      details[:destination].should == "taik"
    end
  end
  
  describe "#send" do
    it "should send the given text as sms to given number"
  end
  
  describe "#get_messages" do
    it "should return an array of hashes containing the messages"
  end
  
  describe "#delete_messages" do
    it "should delete the messages specidied in params from the inbox"
  end
  
end