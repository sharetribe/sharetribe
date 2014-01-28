class TransactionType < ActiveRecord::Base
  attr_accessible :community_id, :price_field, :sort_priority, :type

  belongs_to :community

  has_many :translations, :class_name => "TransactionTypeTranslation", :dependent => :destroy
  has_many :category_transaction_types, :dependent => :destroy
  has_many :categories, :through => :category_transaction_types

end
