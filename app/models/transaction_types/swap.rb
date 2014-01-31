class Swap < TransactionType

  before_validation(:on => :create) do
    price_field = 0
  end

end