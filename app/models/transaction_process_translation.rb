# == Schema Information
#
# Table name: transaction_process_translations
#
#  id                     :integer          not null, primary key
#  transaction_process_id :integer          not null
#  locale                 :string(255)      not null
#  name                   :string(255)
#  action_button_label    :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_transaction_process_translations_on_locale                  (locale)
#  index_transaction_process_translations_on_transaction_process_id  (transaction_process_id)
#

class TransactionProcessTranslation < ActiveRecord::Base
  attr_accessible :locale, :name, :action_button_label

  belongs_to :listing_shape
end
