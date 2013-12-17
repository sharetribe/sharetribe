class DropPaymentGatewaysTable < ActiveRecord::Migration
  def up
    drop_table :payment_gateways
  end

  def down
    create_table :payment_gateways do |t|
      t.string :type
      t.timestamps
    end

    execute("insert into payment_gateways(type) values('Mangopay');")
    execute("insert into payment_gateways(type) values('Checkout');")
    execute("insert into payment_gateways(type) values('BraintreePaymentGateway');")
  end
end
