class MigrateStatusesToTransactionTransitions < ActiveRecord::Migration
  def up
    Conversation.find_each do |conversation|
      transaction_transition = TransactionTransition.new()
      transaction_transition.to_state = conversation.read_attribute(:status)
      transaction_transition.conversation = conversation
      transaction_transition.save!
    end
  end

  def down
    TransactionTransition.delete_all
  end
end
