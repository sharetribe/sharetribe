# == Schema Information
#
# Table name: listing_shapes
#
#  id                         :integer          not null, primary key
#  community_id               :integer          not null
#  transaction_process_id     :integer          not null
#  price_enabled              :boolean          not null
#  shipping_enabled           :boolean          not null
#  name                       :string(255)      not null
#  name_tr_key                :string(255)      not null
#  action_button_tr_key       :string(255)      not null
#  price_quantity_placeholder :string(255)
#  transaction_type_id        :integer
#  sort_priority              :integer          default(0), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_listing_shapes_on_community_id         (community_id)
#  index_listing_shapes_on_name                 (name)
#  index_listing_shapes_on_transaction_type_id  (transaction_type_id)
#

class ListingShape < ActiveRecord::Base
  attr_accessible(
    :community_id,
    :transaction_process_id,
    :price_enabled,
    :shipping_enabled,
    :name,
    :sort_priority,
    :name_tr_key,
    :action_button_tr_key,
    :price_quantity_placeholder,
    :transaction_type_id
  )

  has_many :listing_units
end
