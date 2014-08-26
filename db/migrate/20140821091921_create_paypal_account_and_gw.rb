class CreatePaypalAccountAndGw < ActiveRecord::Migration
  def change
    create_table :paypal_accounts do |t|
      t.string :merchant_id
      t.integer :paypal_payment_gateway_id
      t.string :username
      t.string :api_password
      t.string :signature

      t.timestamps
    end

    create_table :paypal_payment_gateways do |t|
      t.integer :community_id

      t.timestamps
    end
  end
end
