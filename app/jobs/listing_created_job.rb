class ListingCreatedJob < Struct.new(:listing_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community_id parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    listing = Listing.find(listing_id)
    community = Community.find(community_id)
    # Send reminder about missing payment information
    if send_payment_settings_reminder?(listing_id, community)
      MailCarrier.deliver_now(PersonMailer.payment_settings_reminder(listing, listing.author, community))
    end
  end

  def send_payment_settings_reminder?(listing_id, community)
    listing = Listing.find(listing_id)
    payment_type = community.active_payment_types

    query_info = {
      transaction: {
        payment_gateway: payment_type,
        listing_author_id: listing.author.id,
        community_id: community.id
      }
    }

    opts = {
      community_id: community.id,
      process_id: listing.transaction_process_id
    }

    process = TransactionService::API::Api.processes.get(opts).maybe.process.or_else(nil)

    raise ArgumentError.new("Cannot find transaction process: #{opts}") if process.nil?

    payment_type && process == :preauthorize &&
      !TransactionService::Transaction.can_start_transaction(query_info).data[:result]
  end
end
