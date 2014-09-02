class Give < Offer

  DEFAULTS = {
    price_field: 0
  }

  before_validation(:on => :create) do
    self.price_field ||= DEFAULTS[:price_field]
  end

end
