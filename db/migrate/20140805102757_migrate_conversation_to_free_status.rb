require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class MigrateConversationToFreeStatus < ActiveRecord::Migration
  include LoggingHelper

  def up
    convs = ListingConversation.select { |conv| conv.status != "free" && no_payments?(conv.community) }

    puts ""
    puts "This migration will change the status of #{convs.size} conversations to 'free'"
    puts ""

    progress = ProgressReporter.new(convs.size, 100)

    convs.each do |conv|
      conv.transaction_transitions.destroy_all
      state_machine = TransactionProcess.new(conv, transition_class: TransactionTransition)
      state_machine.transition_to! "free"

      progress.next
      print_dot
    end
  end

  def down
  end

  private

  def no_payments?(community)
    community && !community.payments_in_use?
  end
end
