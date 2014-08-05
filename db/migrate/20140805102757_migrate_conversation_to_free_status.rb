class MigrateConversationToFreeStatus < ActiveRecord::Migration
  def up
    convs = ListingConversation.select { |conv| conv.status != "free" && no_payments?(conv.community) }

    convs.each do |conv|
      conv.transaction_transitions.destroy_all
      state_machine = TransactionProcess.new(conv, transition_class: TransactionTransition)
      state_machine.transition_to! "free"
    end
  end

  def down
  end

  private

  def no_payments?(community)
    community && !community.payments_in_use?
  end
end
