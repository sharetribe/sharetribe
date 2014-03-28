class Rent < Offer

  before_validation(:on => :create) do
    self.price_field ||= 1
  end

  def api_name
    "rent_out"
  end

end
