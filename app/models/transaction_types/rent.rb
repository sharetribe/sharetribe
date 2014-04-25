class Rent < Offer

  before_validation(:on => :create) do
    self.price_field ||= 1
  end

end
