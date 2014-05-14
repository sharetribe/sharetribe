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

end
