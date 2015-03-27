# == Schema Information
#
# Table name: listing_shapes
#
#  id                         :integer          not null, primary key
#  community_id               :integer          not null
#  transaction_process_id     :integer          not null
#  price_enabled              :boolean          not null
#  shipping_enabled           :boolean          not null
#  url                        :string(255)      not null
#  name_tr_key                :string(255)      not null
#  action_button_tr_key       :string(255)      not null
#  price_quantity_placeholder :string(255)
#  transaction_type_id        :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_listing_shapes_on_community_id  (community_id)
#  index_listing_shapes_on_url           (url)
#

class ListingShape < ActiveRecord::Base
  attr_accessible(
    :community_id,
    :transaction_process_id,
    :price_enabled,
    :shipping_enabled,
    :url,
    :name_tr_key,
    :action_button_tr_key,
    :price_quantity_placeholder,
    :transaction_type_id
  )
end
