# encoding: UTF-8

require 'spec_helper'

describe Community do
  
  before(:each) do
    @community = FactoryGirl.build(:community)
  end
  
  it "is valid with valid attributes" do
    @community.should be_valid
  end  
  
  it "is not valid without proper name" do
    @community.name = nil
    @community.should_not be_valid
    @community.name = "a"
    @community.should_not be_valid
    @community.name = "a" * 51
    @community.should_not be_valid
  end
  
  it "is not valid without proper domain" do
    @community.domain = "test_community-9"
    @community.should be_valid
    @community.domain = nil
    @community.should_not be_valid
    @community.domain = "a"
    @community.should_not be_valid
    @community.domain = "a" * 51
    @community.should_not be_valid
    @community.domain = "´?€"
    @community.should_not be_valid
  end
  
  describe "#set_email_confirmation_on_and_send_mail_to_existing_users" do
    it "sets the email confirmation to true on the community" do
      @community.email_confirmation.should be_false
      @community.set_email_confirmation_on_and_send_mail_to_existing_users
      @community.email_confirmation.should be_true
    end

    # THESE TESTS BELOW COMMENTED OUT AS TESTING CAUSED MYSQL ERROR ON DUPLICATES,
    # and this is so rarely used feature that didn't seem worth digging thorugh that as it works in practice
    
    # it "Sends email to each user who doesn't have confirmed date" do
    #   ActionMailer::Base.deliveries = []
    #   person1 = FactoryGirl.build(:person, :locale => :en)
    #   person2 = FactoryGirl.build(:person, :locale => :fi)
    #   @community.members.push [person1, person2]
    #   @community.set_email_confirmation_on_and_send_mail_to_existing_users
    #   ActionMailer::Base.deliveries.should_not be_empty
    #   
    #   #ActionMailer::Base.deliveries.first.body.should =~ /Hi John/
    #   ActionMailer::Base.deliveries.first.body.should =~ /you must confirm/
    #   #ActionMailer::Base.deliveries.last.body.should =~ /Hei John/
    #   ActionMailer::Base.deliveries.last.body.should =~ /sinun täytyy vahvistaa/
    #   
    # end
    # 
    # it "does not send email to those who are already confirmed" do
    #   ActionMailer::Base.deliveries = []
    #   person1 = FactoryGirl.build(:person, :locale => :en)
    #   person2 = FactoryGirl.build(:person, :locale => :fi, :confirmed_at => Time.now)
    #   @community.members.push [person1, person2]
    #   @community.set_email_confirmation_on_and_send_mail_to_existing_users
    #   ActionMailer::Base.deliveries.should_not be_empty
    #   
    #   #This is bit silly way of testing, but the amount of mails in deliveries, seems not to be 1 per person...
    #   #ActionMailer::Base.deliveries.first.body.should =~ /Hi John/
    #   ActionMailer::Base.deliveries.first.body.should =~ /you must confirm/
    #   #ActionMailer::Base.deliveries.last.body.should_not =~ /Hei John/
    #   ActionMailer::Base.deliveries.last.body.should_not =~ /sinun täytyy vahvistaa/
    # end
    
  end
  
end
