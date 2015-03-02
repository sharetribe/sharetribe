# == Schema Information
#
# Table name: category_listing_shapes
#
#  id               :integer          not null, primary key
#  category_id      :integer
#  listing_shape_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_category_listing_shapes_on_category_id       (category_id)
#  index_category_listing_shapes_on_listing_shape_id  (listing_shape_id)
#

class CategoryListingShape < ActiveRecord::Base
  belongs_to :category
  belongs_to :listing_shape
end
