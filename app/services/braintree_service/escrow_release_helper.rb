module BraintreeService
  module EscrowReleaseHelper
    include Braintree::Transaction::EscrowStatus

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
        BTLog.error("Transaction '#{transaction_id}' can not be release from escrow: already released/refunded. Status: '#{txn.escrow_status}'")
      else
        BTLog.error("Transaction '#{transaction_id}' can not be release from escrow: unknown status '#{txn.escrow_status}'")
      end
    end

    # privates

    def release_from_escrow_by_community_id(community_id, transaction_id)
      release_from_escrow(Community.find_by_id(community_id), transaction_id)
    end

    def release_from_escrow_after_next_batch(community_id, transaction_id)
      self.delay(:run_at => next_escrow_release_time, :priority => 6).release_from_escrow_by_community_id(community_id, transaction_id)
    end

    # Give a date and get back time of the given date when batch is run
    def settlement_batch_time_per_date(date)
      offset = ActiveSupport::TimeZone.new("Central Time (US & Canada)").formatted_offset
      Time.new(date.year, date.month, date.day, 17, 0, 0, offset)
    end

    # Give a date and get back time of next batch time
    def next_settlement_batch_time(now=Time.now)
      todays_batch = settlement_batch_time_per_date(now)
      tomorrows_batch = settlement_batch_time_per_date(now.tomorrow)

      now < todays_batch ? todays_batch : tomorrows_batch
    end
  end
end
