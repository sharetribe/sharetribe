class Service < TransactionType

  before_validation(:on => :create) do
    price_field = 1
  end

end