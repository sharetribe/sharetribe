class TransactionType < ActiveRecord::Base
  attr_accessible :community_id, :price_field, :sort_priority, :type

  belongs_to :community

  has_many :translations, :class_name => "TransactionTypeTranslation", :dependent => :destroy
  has_many :category_transaction_types, :dependent => :destroy
  has_many :categories, :through => :category_transaction_types
  has_many :listings

  validates_presence_of :community

  def display_name(locale)
    n = translations.find { |translation| translation.locale == locale.to_s } || translations.first # Fallback to first
    n ? n.name : ""
  end

  def action_button_label(locale)
    n = translations.find { |translation| translation.locale == locale.to_s } || translations.first # Fallback to first
    n ? n.action_button_label : ""
  end
end
