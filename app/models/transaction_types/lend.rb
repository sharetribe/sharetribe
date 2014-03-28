class Lend < Offer

  before_validation(:on => :create) do
    self.price_field ||= 0
  end

  def api_name
    "lend"
  end

end
