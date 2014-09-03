# == Schema Information
#
# Table name: transaction_transitions
#
#  id              :integer          not null, primary key
#  to_state        :string(255)
#  metadata        :text
#  sort_key        :integer          default(0)
#  conversation_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class TransactionTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  attr_accessible :to_state, :metadata, :sort_key

  belongs_to :listing_conversation, inverse_of: :transaction_transitions, touch: true
end
