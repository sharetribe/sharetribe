module BraintreeService
  module EscrowReleaseHelper
    include Braintree::Transaction::EscrowStatus

    BATCH_TIMEZONE = "Central Time (US & Canada)"
    BATCH_HOUR = 17

    module_function

    # Get back the next escrow release time
    def next_escrow_release_time(now=Time.now, buffer_hours=2)
      # Let's add 1 hour buffer to give the settlement batch processor some time.
      # And add another 1 hour buffer to make sure this works correctly despite of the daylight saving
      time_buffer = buffer_hours.hours
      next_settlement_batch_time(now) + time_buffer
    end

    def release_from_escrow(community, transaction_id)
      txn = BraintreeApi.find_transaction(community, transaction_id)

      case txn.escrow_status
      when HoldPending
        release_from_escrow_after_next_batch(community.id, transaction_id)
        BTLog.info("Setting release from escrow job for transaction '#{transaction_id}, status: '#{txn.escrow_status}'")
      when Held
        BTLog.info("Releasing transaction '#{transaction_id}' from escrow, status: '#{txn.escrow_status}' ...")
        response = BraintreeApi.release_from_escrow(community, transaction_id)
        BTLog.info("Released transaction '#{transaction_id} from escrow, status: '#{txn.escrow_status}'")
      when ReleasePending, Released, Refunded
        BTLog.error("Transaction '#{transaction_id}' cannot be release from escrow: already released/refunded. Status: '#{txn.escrow_status}'")
      else
        BTLog.error("Transaction '#{transaction_id}' cannot be release from escrow: unknown status '#{txn.escrow_status}'")
      end
    end

    # privates

    def release_from_escrow_by_community_id(community_id, transaction_id)
      release_from_escrow(Community.find_by_id(community_id), transaction_id)
    end

    def release_from_escrow_after_next_batch(community_id, transaction_id)
      self.delay(:run_at => next_escrow_release_time, :priority => 6).release_from_escrow_by_community_id(community_id, transaction_id)
    end

    # Give a date and get back time of next batch time
    def next_settlement_batch_time(now=Time.now)
      next_batch_time = now.in_time_zone(BATCH_TIMEZONE).change(hour: BATCH_HOUR, min: 0, sec: 0)
      next_batch_time += 1.day if next_batch_time < now
      next_batch_time
    end
  end
end
