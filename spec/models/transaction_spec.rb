# == Schema Information
#
# Table name: transactions
#
#  id                                :integer          not null, primary key
#  starter_id                        :string(255)      not null
#  listing_id                        :integer          not null
#  conversation_id                   :integer
#  automatic_confirmation_after_days :integer
#  community_id                      :integer          not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  starter_skipped_feedback          :boolean          default(FALSE)
#  author_skipped_feedback           :boolean          default(FALSE)
#  last_transition_at                :datetime
#
# Indexes
#
#  index_transactions_on_community_id     (community_id)
#  index_transactions_on_conversation_id  (conversation_id)
#  index_transactions_on_listing_id       (listing_id)
#

require 'spec_helper'

describe Transaction do

  before(:each) do
    @transaction = FactoryGirl.build(:transaction, payment: FactoryGirl.build(:braintree_payment))
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
      puts @transaction.preauthorization_expire_at
      puts 5.days.from_now
      @transaction.preauthorization_expire_at.should be_eql days(5)
    end

    it "expires after 5 days, if booking ends after 5 days" do
      @transaction.booking = FactoryGirl.build(:booking, start_on: days(10), end_on: days(12))
      @transaction.preauthorization_expire_at.should be_eql days(5)
    end

    it "expires when the booking ends, if booking ends before 5" do
      ends = days(3)

      @transaction.booking = FactoryGirl.build(:booking, start_on: days(1), end_on: ends.to_date)
      @transaction.preauthorization_expire_at.should be_eql ends
    end
  end

end
