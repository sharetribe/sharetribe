class Service < Offer

  DEFAULTS = {
    price_field: 1,
    price_quantity_placeholder: "time"
  }

  before_validation(:on => :create) do
    self.price_field ||= DEFAULTS[:price_field]
    self.price_quantity_placeholder ||= DEFAULTS[:price_quantity_placeholder]
  end

end
