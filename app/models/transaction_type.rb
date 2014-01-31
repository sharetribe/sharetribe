class TransactionType < ActiveRecord::Base
  attr_accessible :community_id, :price_field, :sort_priority, :type

  belongs_to :community

  has_many :translations, :class_name => "TransactionTypeTranslation", :dependent => :destroy
  has_many :category_transaction_types, :dependent => :destroy
  has_many :categories, :through => :category_transaction_types

  validates_presence_of :community

  def name(locale="en")
    n = translations.find { |translation| translation.locale == locale.to_s } || translations.first # Fallback to first
    n ? n.name : ""
  end

end
