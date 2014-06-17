class TransactionTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  attr_accessible :to_state, :metadata, :sort_key

  belongs_to :listing_conversation, inverse_of: :transaction_transitions
end
