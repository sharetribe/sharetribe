# == Schema Information
#
# Table name: category_listing_shapes
#
#  category_id      :integer          not null
#  listing_shape_id :integer          not null
#
# Indexes
#
#  index_category_listing_shapes_on_category_id  (category_id)
#  unique_listing_shape_category_joins           (listing_shape_id,category_id) UNIQUE
#

class CategoryListingShape < ApplicationRecord
  belongs_to :category
  belongs_to :listing_shape
end
