# == Schema Information
#
# Table name: bookings
#
#  id             :integer          not null, primary key
#  transaction_id :integer
#  start_on       :date
#  end_on         :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe Booking do
  describe "validations" do

    it "does not allow start time to be in the past" do
      booking = FactoryGirl.build(:booking, start_on: 1.day.ago, end_on: 2.days.from_now)
      booking.should_not be_valid
    end

    it "ensures end time is >= start time" do
      booking = FactoryGirl.build(:booking, start_on: 5.days.from_now, end_on: 2.days.from_now)
      booking.should_not be_valid
    end

  end
end
