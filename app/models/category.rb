class Category < ActiveRecord::Base
  attr_accessible :community_id, :parent_id, :translation_attributes, :transaction_type_attributes, :sort_priority

  # Classification module contains methods that are common to Category and ShareType
  include Classification

  has_many :subcategories, :class_name => "Category", :foreign_key => "parent_id", :dependent => :destroy, :order => "sort_priority"
  # children is a more generic alias for sub categories, used in classification.rb
  has_many :children, :class_name => "Category", :foreign_key => "parent_id", :order => "sort_priority"
  belongs_to :parent, :class_name => "Category"
  has_many :listings
  has_many :translations, :class_name => "CategoryTranslation", :dependent => :destroy

  has_many :category_custom_fields, :dependent => :destroy
  has_many :custom_fields, :through => :category_custom_fields

  has_many :category_transaction_types, :dependent => :destroy
  has_many :transaction_types, :through => :category_transaction_types
  
  belongs_to :community

  before_destroy :can_destroy?

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

  def transaction_type_attributes=(attributes)
    transaction_types.clear
    attributes.each { |transaction_type| category_transaction_types.build(transaction_type) }
  end

  def display_name(locale="en")
    n = translations.find { |translation| translation.locale == locale.to_s } || translations.first # Fallback to first
    n ? n.name : ""
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

  # Please note! At the moment this is only used in tests. Consider moving this out of production code.
  def self.find_by_community_and_translation(community, category_name)
    community.categories.
      select { |category| category.translations.
        any? { |translation| translation.name == category_name} }.
      first
  end
end
