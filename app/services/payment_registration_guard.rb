class PaymentRegistrationGuard

  def initialize(community, user, listing)
    @community = community
    @user = user
    @listing = listing
  end

  def requires_registration_before_accepting?
    requires_registration?
  end

  def requires_registration_before_posting?
    requires_registration? && preauthorize_flow_in_use?
  end

  private

  def requires_registration?
    @listing.payment_required_at?(@community) && not_registered_already?
  end

  def preauthorize_flow_in_use?
    @listing.transaction_type.preauthorize_payment?
  end

  def not_registered_already?
    !@community.payment_gateway.can_receive_payments?(@user)
  end
end
