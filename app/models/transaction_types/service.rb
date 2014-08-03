class Service < Offer

  before_validation(:on => :create) do
    self.price_field ||= 1
    self.price_quantity_placeholder ||= "time"
  end

end
