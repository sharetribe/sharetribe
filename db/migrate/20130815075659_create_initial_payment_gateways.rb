class CreateInitialPaymentGateways < ActiveRecord::Migration[5.2]
  def up

  end

  def down
    Mangopay.last.destroy
    Checkout.last.destroy
  end
end
