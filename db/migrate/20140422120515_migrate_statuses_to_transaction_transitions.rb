require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class MigrateStatusesToTransactionTransitions < ActiveRecord::Migration
  include LoggingHelper

  def up
    progress = ProgressReporter.new(Conversation.count, 500)
    Conversation.find_each do |conversation|
      transaction_transition = TransactionTransition.new()
      transaction_transition.to_state = conversation.read_attribute(:status)
      transaction_transition.conversation = conversation
      transaction_transition.save!
      print_dot
      progress.next
    end
  end

  def down
    TransactionTransition.delete_all
  end
end
