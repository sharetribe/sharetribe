# == Schema Information
#
# Table name: listing_units
#
#  id                :integer          not null, primary key
#  unit_type         :string(32)       not null
#  quantity_selector :string(32)       not null
#  translation_key   :string(64)
#  listing_shape_id  :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_listing_units_on_listing_shape_id     (listing_shape_id)
#  index_listing_units_on_transaction_type_id  (transaction_type_id)
#

class ListingUnit < ActiveRecord::Base
  attr_accessible(
    :listing_shape_id,
    :unit_type,
    :translation_key,
    :quantity_selector
  )

  def self.columns
    super.reject { |c| c.name == "transaction_type_id" }
  end
end
