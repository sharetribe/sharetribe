# == Schema Information
#
# Table name: transaction_transitions
#
#  id             :integer          not null, primary key
#  to_state       :string(255)
#  metadata       :text
#  sort_key       :integer          default(0)
#  transaction_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_transaction_transitions_on_conversation_id               (transaction_id)
#  index_transaction_transitions_on_sort_key_and_conversation_id  (sort_key,transaction_id) UNIQUE
#

class TransactionTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  attr_accessible :to_state, :metadata, :sort_key

  belongs_to :transaction, inverse_of: :transaction_transitions, touch: true
end
