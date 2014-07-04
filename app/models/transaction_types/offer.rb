class Offer < TransactionType

  def direction
    "offer"
  end

  def is_offer?
    true
  end

  def is_request?
    false
  end

  def is_inquiry?
    false
  end

  def status_after_reply
    if price_field? && community.payments_in_use?
      if preauthorize_payment?
        "preauthorize"
      else
        "pending"
      end
    else
      "free"
    end
  end

end
