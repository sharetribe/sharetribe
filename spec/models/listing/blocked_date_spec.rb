# == Schema Information
#
# Table name: listing_blocked_dates
#
#  id         :bigint           not null, primary key
#  listing_id :bigint
#  blocked_at :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_listing_blocked_dates_on_listing_id  (listing_id)
#

require 'rails_helper'

RSpec.describe Listing::BlockedDate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
