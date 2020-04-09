class CreateInitialPaymentGateways < ActiveRecord::Migration[5.2]
def up
    Mangopay.create unless Mangopay.count > 0
    Checkout.create unless Checkout.count > 0
  end

  def down
    Mangopay.last.destroy
    Checkout.last.destroy
  end
end
