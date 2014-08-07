require 'spec_helper'

describe ListingConversation do

  before(:each) do
    @listing_conversation = FactoryGirl.build(:listing_conversation, payment: FactoryGirl.build(:braintree_payment))
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  describe "#preauthorization_expire_at" do

    it "expires after 5 days" do
      puts @listing_conversation.preauthorization_expire_at
      puts 5.days.from_now
      @listing_conversation.preauthorization_expire_at.should be_eql 5.days.from_now
    end

    it "expires after 5 days, if booking ends after 5 days" do
      @listing_conversation.booking = FactoryGirl.build(:booking, start_on: 10.days.from_now, end_on: 12.days.from_now)
      @listing_conversation.preauthorization_expire_at.should be_eql 5.days.from_now
    end

    it "expires when the booking ends, if booking ends before 5" do
      ends = 3.days.from_now

      @listing_conversation.booking = FactoryGirl.build(:booking, start_on: 1.days.from_now, end_on: ends)
      @listing_conversation.preauthorization_expire_at.should be_eql ends
    end
  end

end
