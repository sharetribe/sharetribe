class ShareForFree < Offer

  before_validation(:on => :create) do
    self.price_field ||= 0
  end

end
