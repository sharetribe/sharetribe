class StripeService::Report

  private

  attr_reader :tx, :exception

  public

  def initialize(tx:, exception: nil)
    @tx = tx
    @exception = exception
  end

  def capture_charge_start
    result = capture_charge.merge({
      "stripe_op": "capture_charge",
      "event": "stripe_call",
    })
    logger.info('capture_charge_start', nil, result)
    result
  end

  def capture_charge_success
    result = capture_charge.merge({
      "stripe_op": "capture_charge",
      "event": "stripe_call_succeeded",
      "stripe_charge_state": "success"
    })
    logger.info('capture_charge_success', nil, result)
    result
  end

  def capture_charge_failed
    result = capture_charge.merge({
      "stripe_op": "capture_charge",
      "event": "stripe_call_failed",
      "stripe_error":     {
        "message": exception&.message,
        "code": exception&.code,
      }
    })
    logger.info('capture_charge_failed', nil, result)
    result
  end

  private

  def capture_charge
    {
      "transaction_id": tx.id,
      "stripe_payment_id": stripe_payment.id,
      "stripe_seller_id": stripe_account.stripe_seller_id,
      "stripe_charge_id": stripe_payment.stripe_charge_id
    }
  end

  def stripe_payment
    return @stripe_payment if defined?(@stripe_payment)
    @stripe_payment = StripePayment.find_by(transaction_id: tx.id)
  end

  def stripe_account
    return @stripe_account if defined?(@stripe_account)
    receiver = stripe_payment&.receiver
    @stripe_account = receiver && StripeAccount.find_by(person: receiver)
  end

  def logger
    @logger ||= SharetribeLogger.new(:stripe, logger_metadata.keys).tap { |logger|
      logger.add_metadata(logger_metadata)
    }
  end

  def logger_metadata
    { transaction_id: tx.id }
  end
end
