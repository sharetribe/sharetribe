# == Schema Information
#
# Table name: listing_working_time_slots
#
#  id         :integer          not null, primary key
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
  pending "add some examples to (or delete) #{__FILE__}"
end
