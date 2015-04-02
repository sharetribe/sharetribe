# == Schema Information
#
# Table name: listing_units
#
#  id                  :integer          not null, primary key
#  unit_type           :string(32)       not null
#  translation_key     :string(64)
#  transaction_type_id :integer
#  listing_shape_id    :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_listing_units_on_listing_shape_id     (listing_shape_id)
#  index_listing_units_on_transaction_type_id  (transaction_type_id)
#

class ListingUnit < ActiveRecord::Base
  attr_accessible(
    :transaction_type_id,
    :listing_shape_id,
    :unit_type,
    :translation_key
  )
end
