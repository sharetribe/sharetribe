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
# Indexes
#
#  index_bookings_on_transaction_id  (transaction_id)
#

require 'spec_helper'

describe Booking, type: :model do
  describe "validations" do
    it "ensures end time is >= start time" do
      booking = FactoryGirl.build(:booking, start_on: 5.days.from_now, end_on: 2.days.from_now)
      expect(booking).not_to be_valid
    end
  end
end
