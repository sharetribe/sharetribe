class Category < ActiveRecord::Base

  attr_accessible :community_id, :parent_id, :translation_attributes, :transaction_type_attributes

  # Classification module contains methods that are common to Category and ShareType
  include Classification

  has_many :subcategories, :class_name => "Category", :foreign_key => "parent_id", :dependent => :destroy
  # children is a more generic alias for sub categories, used in classification.rb
  has_many :children, :class_name => "Category", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Category"
  has_many :community_categories, :dependent => :destroy 
  has_many :communities, :through => :community_categories
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

  def has_listings?
    listings.count > 0
  end

  def has_subcategories?
    subcategories.count > 0
  end

  def subcategory_ids
    subcategories.collect(&:id)
  end

  def own_and_subcategory_ids
    [id].concat(subcategory_ids)
  end

  def is_own_or_subcategory_id?(id)
    own_and_subcategory_ids.include?(id)
  end

  def all_but_me
    community.categories.select do |category|
      !is_own_or_subcategory_id?(category.id)
    end
  end

  def is_subcategory?
    !parent_id.nil?
  end

  def can_destroy?
    is_subcategory? || community.top_level_categories.count > 1
  end

  def remove_needs_caution?
    has_listings? or has_subcategories?
  end

  def own_and_subcategory_listings
    Listing.find_by_category_and_subcategory(self)
  end
end
