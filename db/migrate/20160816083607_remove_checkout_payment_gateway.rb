class RemoveCheckoutPaymentGateway < ActiveRecord::Migration[5.2]
def up
    execute("
      DELETE FROM payment_gateways WHERE type = 'Checkout'
    ")
  end

  def down
    # Nothing here
  end
end
