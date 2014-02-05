class Offer < TransactionType

  DIRECTION = "offer"
  IS_OFFER = true
  IS_REQUEST = false

  def direction
    "offer"
  end

  def is_offer?
    true
  end

  def is_request?
    
  end

end