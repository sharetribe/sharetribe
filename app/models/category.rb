class Category < ActiveRecord::Base

  # Classification module contains methods that are common to Category and ShareType
  include Classification

  has_many :subcategories, :class_name => "Category", :foreign_key => "parent_id"
  # children is a more generic alias for sub categories, used in classification.rb
  has_many :children, :class_name => "Category", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Category"
  has_many :community_categories, :dependent => :destroy 
  has_many :communities, :through => :community_categories
  has_many :listings
  has_many :translations, :class_name => "CategoryTranslation", :dependent => :destroy

  has_many :category_custom_fields, :dependent => :destroy
  has_many :custom_fields, :through => :category_custom_fields
  
  belongs_to :community

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

  def display_name(locale="en")
    n = translations.find { |translation| translation.locale == locale.to_s } || translations.first # Fallback to first
    n ? n.name : ""
  end

end
