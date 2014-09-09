class PaymentMailCreator

  def initialize(transaction, community)
    @payment, @community = payment, community
    @gateway = @community.payment_gateway
  end

  def new_payment
    case @gateway.type
    when "BraintreePaymentGateway"
      PersonMailer.braintree_new_payment(@payment, @community)
    else
      PersonMailer.new_payment(@payment, @community)
    end
  end

  def receipt_to_payer
    case @gateway.type
    when "BraintreePaymentGateway"
      PersonMailer.braintree_receipt_to_payer(@payment, @community)
    else
      PersonMailer.receipt_to_payer(@payment, @community)
    end
  end
end
