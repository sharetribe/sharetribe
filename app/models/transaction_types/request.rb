class Request < TransactionType

  before_validation(:on => :create) do
    self.price_field ||= 0
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

end