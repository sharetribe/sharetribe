# == Schema Information
#
# Table name: listing_shapes
#
#  id                         :integer          not null, primary key
#  community_id               :integer          not null
#  transaction_type_id        :integer          not null
#  sort_priority              :integer
#  price_enabled              :boolean          not null
#  price_quantity_placeholder :string(255)
#  price_per                  :string(255)
#  url                        :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_listing_shapes_on_community_id  (community_id)
#  index_listing_shapes_on_url           (url)
#

class ListingShape < ActiveRecord::Base
  attr_accessible :price_enabled, :price_per, :transaction_process_id, :transaction_type_id, :url

  has_one :transaction_process

  def self.find_by_param(id_or_url)
    where("id = ? OR url = ?", id_or_url, id_or_url).first
  end
end
