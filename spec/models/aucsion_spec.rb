# == Schema Information
#
# Table name: aucsions
#
#  id                  :bigint           not null, primary key
#  listing_id          :bigint
#  person_id           :string(255)
#  price_aucsion_cents :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_aucsions_on_listing_id  (listing_id)
#

require 'rails_helper'

RSpec.describe Aucsion, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
