class Request < TransactionType

  DIRECTION = "request"
  IS_OFFER = false
  IS_REQUEST = true

  before_validation(:on => :create) do
    self.price_field ||= 0
  end

end