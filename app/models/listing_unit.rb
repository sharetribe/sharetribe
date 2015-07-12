# == Schema Information
#
# Table name: listing_units
#
#  id                :integer          not null, primary key
#  unit_type         :string(32)       not null
#  quantity_selector :string(32)       not null
#  kind              :string(32)       not null
#  name_tr_key       :string(64)
#  selector_tr_key   :string(64)
#  listing_shape_id  :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_listing_units_on_listing_shape_id  (listing_shape_id)
#

class ListingUnit < ActiveRecord::Base
  attr_accessible(
    :listing_shape_id,
    :unit_type,
    :name_tr_key,
    :selector_tr_key,
    :quantity_selector,
    :kind
  )

  def self.columns
    super.reject { |c| c.name == "translation_key"}
  end
end
