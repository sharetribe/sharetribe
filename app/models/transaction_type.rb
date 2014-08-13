# == Schema Information
#
# Table name: transaction_types
#
#  id                         :integer          not null, primary key
#  type                       :string(255)
#  community_id               :integer
#  sort_priority              :integer
#  price_field                :boolean
#  preauthorize_payment       :boolean          default(FALSE)
#  price_quantity_placeholder :string(255)
#  price_per                  :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class TransactionType < ActiveRecord::Base
  attr_accessible :community_id, :price_field, :sort_priority, :type, :price_quantity_placeholder

  belongs_to :community

  has_many :translations, :class_name => "TransactionTypeTranslation", :dependent => :destroy, inverse_of: :transaction_type
  has_many :category_transaction_types, :dependent => :destroy
  has_many :categories, :through => :category_transaction_types
  has_many :listings

  validates_presence_of :community

  def display_name(locale)
    TranslationCache.new(self, :translations).translate(locale, :name)
  end

  def action_button_label(locale)
    TranslationCache.new(self, :translations).translate(locale, :action_button_label)
  end

  def status_after_reply
    "free"
  end
end
