# == Schema Information
#
# Table name: categories
#
#  id            :integer          not null, primary key
#  parent_id     :integer
#  icon          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  community_id  :integer
#  sort_priority :integer
#  url           :string(255)
#
# Indexes
#
#  index_categories_on_community_id  (community_id)
#  index_categories_on_parent_id     (parent_id)
#  index_categories_on_url           (url)
#
class CategorySerializer < ActiveModel::Serializer
   attributes :id, :parent_id, :icon, :sort_priority, :url

   has_many :children
   has_many :subcategories
   has_many :translations
end