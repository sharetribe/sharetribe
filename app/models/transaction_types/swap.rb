class Swap < Offer

  before_validation(:on => :create) do
    price_field = 0
  end

  def api_name
    "offer_to_swap"
  end

end
