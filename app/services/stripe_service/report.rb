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
      "event": "stripe_call"
    })
    logger.info('capture_charge_start', nil, result)
    result
  end

  def capture_charge_success
    result = capture_charge.merge({
      "event": "stripe_call_succeeded",
      "stripe_charge_state": "success"
    })
    logger.info('capture_charge_success', nil, result)
    result
  end

  def capture_charge_failed
    result = capture_charge.merge({
      "event": "stripe_call_failed",
      "stripe_error": stripe_error
    })
    logger.info('capture_charge_failed', nil, result)
    result
  end

  def create_charge_start
    result = create_charge.merge({
      "event": "stripe_call"
    })
    logger.info('create_charge_start', nil, result)
    result
  end

  def create_charge_success
    stripe_payment.reload
    result = create_charge.merge({
      "event": "stripe_call_succeeded",
      "stripe_payment_id": stripe_payment.id,
      "stripe_charge_id": stripe_payment.stripe_charge_id,
      "stripe_charge_state": "success"
    })
    logger.info('create_charge_success', nil, result)
    result
  end

  def create_charge_failed
    result = create_charge.merge({
      "event": "stripe_call_failed",
      "stripe_payment_id": stripe_payment&.id,
      "stripe_error": stripe_error
    })
    logger.info('create_charge_failed', nil, result)
    result
  end

  def cancel_charge_start
    result = cancel_charge.merge({
      "event": "stripe_call"
    })
    logger.info('cancel_charge_start', nil, result)
    result
  end

  def cancel_charge_success
    stripe_payment.reload
    result = cancel_charge.merge({
      "event": "stripe_call_succeeded",
      "stripe_charge_state": "success"
    })
    logger.info('cancel_charge_success', nil, result)
    result
  end

  def cancel_charge_failed
    result = cancel_charge.merge({
      "event": "stripe_call_failed",
      "stripe_error": stripe_error
    })
    logger.info('cancel_charge_failed', nil, result)
    result
  end

  def create_payout_start
    result = create_payout.merge({
      "event": "stripe_call"
    })
    logger.info('create_payout_start', nil, result)
    result
  end

  def create_payout_success
    stripe_payment.reload
    result = create_payout.merge({
      "event": "stripe_call_succeeded",
      "stripe_payment_id": stripe_payment.id,
      "stripe_charge_id": stripe_payment.stripe_charge_id,
      "stripe_payment_intent_id": stripe_payment.stripe_payment_intent_id,
      "stripe_transfer_id": stripe_payment.stripe_transfer_id
    })
    logger.info('create_payout_success', nil, result)
    result
  end

  def create_payout_failed
    result = create_payout.merge({
      "event": "stripe_call_failed",
      "stripe_payment_id": stripe_payment&.id,
      "stripe_error": stripe_error
    })
    logger.info('create_payout_failed', nil, result)
    result
  end

  def create_intent_start
    result = create_intent.merge({
      "event": "stripe_call"
    })
    logger.info('create_intent_start', nil, result)
    result
  end

  def create_intent_success
    stripe_payment.reload
    result = create_intent.merge({
      "event": "stripe_call_succeeded",
      "stripe_payment_id": stripe_payment.id,
      "stripe_charge_id": stripe_payment.stripe_charge_id,
      "stripe_payment_intent_id": stripe_payment.stripe_payment_intent_id,
      "stripe_charge_state": "success"
    })
    logger.info('create_intent_success', nil, result)
    result
  end

  def create_intent_failed
    result = create_intent.merge({
      "event": "stripe_call_failed",
      "stripe_payment_id": stripe_payment&.id,
      "stripe_error": stripe_error
    })
    logger.info('create_intent_failed', nil, result)
    result
  end

  def cancel_intent_start
    result = cancel_intent.merge({
      "event": "stripe_call"
    })
    logger.info('cancel_intent_start', nil, result)
    result
  end

  def cancel_intent_success
    stripe_payment.reload
    result = cancel_intent.merge({
      "event": "stripe_call_succeeded",
      "stripe_charge_state": "success"
    })
    logger.info('cancel_intent_success', nil, result)
    result
  end

  def cancel_intent_failed
    result = cancel_intent.merge({
      "event": "stripe_call_failed",
      "stripe_error": stripe_error
    })
    logger.info('cancel_intent_failed', nil, result)
    result
  end

  def capture_intent_start
    result = capture_intent.merge({
      "event": "stripe_call"
    })
    logger.info('capture_intent_start', nil, result)
    result
  end

  def capture_intent_success
    result = capture_intent.merge({
      "event": "stripe_call_succeeded",
      "stripe_charge_state": "success"
    })
    logger.info('capture_intent_success', nil, result)
    result
  end

  def capture_intent_failed
    result = capture_intent.merge({
      "event": "stripe_call_failed",
      "stripe_error": stripe_error
    })
    logger.info('capture_intent_failed', nil, result)
    result
  end

  private

  def capture_charge
    {
      "stripe_op": "capture_charge",
      "transaction_id": tx.id,
      "stripe_payment_id": stripe_payment.id,
      "stripe_seller_id": stripe_account.stripe_seller_id,
      "stripe_charge_id": stripe_payment.stripe_charge_id
    }
  end

  def create_charge
    {
      "stripe_op": "create_charge",
      "transaction_id": tx.id,
      "stripe_seller_id": stripe_account.stripe_seller_id
    }
  end

  def cancel_charge
    {
      "stripe_op": "cancel_charge",
      "transaction_id": tx.id,
      "stripe_seller_id": stripe_account.stripe_seller_id,
      "stripe_payment_id": stripe_payment.id,
      "stripe_charge_id": stripe_payment.stripe_charge_id
    }
  end

  def create_payout
    {
      "stripe_op": "create_payout",
      "transaction_id": tx.id,
      "stripe_payment_id": stripe_payment.id,
      "stripe_seller_id": stripe_account.stripe_seller_id,
      "stripe_charge_id": stripe_payment.stripe_charge_id
    }
  end

  def create_intent
    {
      "stripe_op": "create_intent",
      "transaction_id": tx.id,
      "stripe_seller_id": stripe_account.stripe_seller_id
    }
  end

  def cancel_intent
    {
      "stripe_op": "cancel_intent",
      "transaction_id": tx.id,
      "stripe_payment_id": stripe_payment.id,
      "stripe_seller_id": stripe_account.stripe_seller_id,
      "stripe_charge_id": stripe_payment.stripe_charge_id,
      "stripe_payment_intent_id": stripe_payment.stripe_payment_intent_id
    }
  end

  def capture_intent
    {
      "stripe_op": "capture_intent",
      "transaction_id": tx.id,
      "stripe_payment_id": stripe_payment.id,
      "stripe_seller_id": stripe_account.stripe_seller_id,
      "stripe_charge_id": stripe_payment.stripe_charge_id,
      "stripe_payment_intent_id": stripe_payment.stripe_payment_intent_id
    }
  end

  def stripe_payment
    return @stripe_payment if defined?(@stripe_payment)

    @stripe_payment = StripePayment.find_by(transaction_id: tx.id)
  end

  def stripe_account
    return @stripe_account if defined?(@stripe_account)

    @stripe_account = StripeAccount.find_by(person: tx.author)
  end

  def logger
    @logger ||= SharetribeLogger.new(:stripe, logger_metadata.keys).tap { |logger|
      logger.add_metadata(logger_metadata)
    }
  end

  def logger_metadata
    { transaction_id: tx.id }
  end

  def stripe_error
    if exception
      {
        "message": exception.try(:message),
        "code": exception.try(:code),
        "decline_code": exception.try(:json_body).try(:[],:error).try(:[], :decline_code)
      }
    else
      {}
    end
  end
end
