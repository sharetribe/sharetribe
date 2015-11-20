class PaymentRegistrationGuard

  def initialize(community, user, listing)
    @community = community
    @user = user
    @listing = listing
  end

  def requires_registration_before_accepting?
    @listing.price && @listing.price > 0 && @community.payments_in_use? && not_registered_already?
  end

  def requires_registration_before_posting?
    find_opts = { community_id: @community.id, listing_shape_id: @listing.listing_shape_id }
    res = ListingService::API::Api.shapes.get(find_opts)

    price_enabled = res.maybe.map { |shape|
      shape[:price_enabled]
    }.or_else(nil).tap { |result|
      raise ArgumentError.new("Cannot find shape: #{find_opts}") if result.nil?
    }

    price_enabled && not_registered_already? && preauthorize_flow_in_use?
  end

  private

  def preauthorize_flow_in_use?
    opts = {
      community_id: @community.id,
      process_id: @listing.transaction_process_id
    }

    TransactionService::API::Api.processes.get(opts)
      .maybe[:process]
      .map { |process| process == :preauthorize }
      .tap { |process|
      raise ArgumentError.new("Cannot find transaction process: #{opts}") if process.nil?
    }
  end

  def not_registered_already?
    !@community.payment_gateway.can_receive_payments?(@user)
  end
end
