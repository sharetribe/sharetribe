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

class ListingUnit < ActiveRecord::Base
  attr_accessible(
    :transaction_type_id,
    :listing_shape_id,
    :unit_type,
    :translation_key
  )
end
