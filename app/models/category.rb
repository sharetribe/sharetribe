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
#  index_categories_on_parent_id  (parent_id)
#  index_categories_on_url        (url)
#

class Category < ActiveRecord::Base
  attr_accessible :community_id, :parent_id, :translation_attributes, :transaction_type_attributes, :sort_priority, :url

  has_many :subcategories, :class_name => "Category", :foreign_key => "parent_id", :dependent => :destroy, :order => "sort_priority"
  # children is a more generic alias for sub categories, used in classification.rb
  has_many :children, :class_name => "Category", :foreign_key => "parent_id", :order => "sort_priority"
  belongs_to :parent, :class_name => "Category"
  has_many :listings
  has_many :translations, :class_name => "CategoryTranslation", :dependent => :destroy

  has_many :category_custom_fields, :dependent => :destroy
  has_many :custom_fields, :through => :category_custom_fields, :order => "sort_priority"

  has_many :category_transaction_types, :dependent => :destroy
  has_many :transaction_types, :through => :category_transaction_types

  belongs_to :community

  before_destroy :can_destroy?

  acts_as_url :url_source, scope: :community_id, sync_url: true, blacklist: %w{new all}

  def translation_attributes=(attributes)
    build_attrs = attributes.map { |locale, values| { locale: locale, values: values } }
    build_attrs.each do |translation|
      if existing_translation = translations.find_by_locale(translation[:locale])
        existing_translation.update_attributes(translation[:values])
      else
        translations.build(translation[:values].merge({:locale => translation[:locale]}))
      end
    end
  end

  def to_param
    url
  end

  def url_source
    Maybe(default_translation_without_cache).name.or_else("category")
  end

  def default_translation_without_cache
    (translations.find { |translation| translation.locale == community.default_locale } || translations.first)
  end

  def transaction_type_attributes=(attributes)
    transaction_types.clear
    attributes.each { |transaction_type| category_transaction_types.build(transaction_type) }
  end

  def display_name(locale)
    TranslationCache.new(self, :translations).translate(locale, :name)
  end

  def has_own_or_subcategory_listings?
    listings.count > 0 || subcategories.any? { |subcategory| !subcategory.listings.empty? }
  end

  def has_subcategories?
    subcategories.count > 0
  end

  def has_own_or_subcategory_custom_fields?
    custom_fields.count > 0 || subcategories.any? { |subcategory| !subcategory.custom_fields.empty? }
  end

  def subcategory_ids
    subcategories.collect(&:id)
  end

  def own_and_subcategory_ids
    [id].concat(subcategory_ids)
  end

  def is_subcategory?
    !parent_id.nil?
  end

  def can_destroy?
    is_subcategory? || community.top_level_categories.count > 1
  end

  def remove_needs_caution?
    has_own_or_subcategory_listings? or has_subcategories?
  end

  def own_and_subcategory_listings
    Listing.find_by_category_and_subcategory(self)
  end

  def own_and_subcategory_custom_fields
    CategoryCustomField.find_by_category_and_subcategory(self).includes(:custom_field).collect(&:custom_field)
  end

  def with_all_children
    # first add self
    child_array = [self]

    # Then add children with their children too
    children.each do |child|
      child_array << child.with_all_children
    end

    return child_array.flatten
  end

  def icon_name
    return icon if ApplicationHelper.icon_specified?(icon)
    return parent.icon_name if parent
    return "other"
  end

  def self.find_by_url_or_id(url_or_id)
    self.find_by_url(url_or_id) || self.find_by_id(url_or_id)
  end
end
