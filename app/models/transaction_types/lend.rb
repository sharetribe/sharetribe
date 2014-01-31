class Lend < TransactionType

  before_validation(:on => :create) do
    self.price_field ||= 0
  end

end