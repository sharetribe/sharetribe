# == Schema Information
#
# Table name: listing_working_time_slots
#
#  id         :bigint           not null, primary key
#  listing_id :integer
#  week_day   :integer
#  from       :string(255)
#  till       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_listing_working_time_slots_on_listing_id  (listing_id)
#

require 'spec_helper'

RSpec.describe Listing::WorkingTimeSlot, type: :model do
  describe 'from till' do
    it 'Validates from is less than till' do
      working_time_slot = Listing::WorkingTimeSlot.new
      working_time_slot.from = '10:00'
      working_time_slot.till = '11:00'
      expect(working_time_slot.valid?).to eq true
      working_time_slot.from = '00:00'
      working_time_slot.till = '24:00'
      expect(working_time_slot.valid?).to eq true
      working_time_slot.from = '12:00'
      working_time_slot.till = '11:00'
      expect(working_time_slot.valid?).to eq false
      working_time_slot.from = '10:00'
      working_time_slot.till = '10:00'
      expect(working_time_slot.valid?).to eq false
    end
  end
end
