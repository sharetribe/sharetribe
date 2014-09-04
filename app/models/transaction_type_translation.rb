# == Schema Information
#
# Table name: transaction_type_translations
#
#  id                  :integer          not null, primary key
#  transaction_type_id :integer
#  locale              :string(255)
#  name                :string(255)
#  action_button_label :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_transaction_type_translations_on_transaction_type_id  (transaction_type_id)
#  locale_index                                                (transaction_type_id,locale)
#

class TransactionTypeTranslation < ActiveRecord::Base
  attr_accessible :action_button_label, :locale, :name, :transaction_type_id

  belongs_to :transaction_type, touch: true

  validates_presence_of :transaction_type
  validates_presence_of :locale
end
