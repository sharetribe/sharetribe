class Request < TransactionType

  DEFAULTS = {
    price_field: 0
  }

  before_validation(:on => :create) do
    self.price_field ||= DEFAULTS[:price_field]
  end

  def direction
    "request"
  end

  def is_offer?
    false
  end

  def is_request?
    true
  end

  def is_inquiry?
    false
  end

end
