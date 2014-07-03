class PaymentRegistrationGuard

  def initialize(community, user, listing)
    @community = community
    @user = user
    @listing = listing
  end

  def requires_registration?
    @listing.payment_required_at?(@community) && !@community.payment_gateway.can_receive_payments?(@user)
  end
end
