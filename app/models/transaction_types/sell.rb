class Sell < Offer

  DEFAULTS = {
    price_field: 1
  }

  before_validation(:on => :create) do
    self.price_field ||= DEFAULTS[:price_field]
  end

end
