class RemoveCheckoutPaymentGateway < ActiveRecord::Migration
  def up
    execute("
      DELETE FROM payment_gateways WHERE type = 'Checkout'
    ")
  end

  def down
    # Nothing here
  end
end
