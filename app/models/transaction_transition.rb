# == Schema Information
#
# Table name: transaction_transitions
#
#  id             :integer          not null, primary key
#  to_state       :string(255)
#  metadata       :text(65535)
#  sort_key       :integer          default(0)
#  transaction_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  most_recent    :boolean
#
# Indexes
#
#  index_transaction_transitions_on_conversation_id               (transaction_id)
#  index_transaction_transitions_on_sort_key_and_conversation_id  (sort_key,transaction_id) UNIQUE
#

class TransactionTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id", inverse_of: :transaction_transitions, touch: true
end
