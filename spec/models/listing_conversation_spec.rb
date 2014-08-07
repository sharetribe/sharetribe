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

    def days(num)
      num.days.from_now.to_date
    end

    it "expires after 5 days" do
      puts @listing_conversation.preauthorization_expire_at
      puts 5.days.from_now
      @listing_conversation.preauthorization_expire_at.should be_eql days(5)
    end

    it "expires after 5 days, if booking ends after 5 days" do
      @listing_conversation.booking = FactoryGirl.build(:booking, start_on: days(10), end_on: days(12))
      @listing_conversation.preauthorization_expire_at.should be_eql days(5)
    end

    it "expires when the booking ends, if booking ends before 5" do
      ends = days(3)

      @listing_conversation.booking = FactoryGirl.build(:booking, start_on: days(1), end_on: ends.to_date)
      @listing_conversation.preauthorization_expire_at.should be_eql ends
    end
  end

end
