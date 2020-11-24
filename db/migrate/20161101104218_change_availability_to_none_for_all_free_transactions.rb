class ChangeAvailabilityToNoneForAllFreeTransactions < ActiveRecord::Migration
  def up
    name = "Change availability to :none for all :free transactions"

    exec_update([
                  "UPDATE transactions SET availability = 'none'",
                  "WHERE availability = 'booking'",
                  "AND payment_process = 'none'"
                ].join(" "), name, [])
  end
end
