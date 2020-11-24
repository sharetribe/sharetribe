class CreatePaypalPayments < ActiveRecord::Migration
  def change
    create_table :paypal_payments do |t|
      t.integer  :transaction_id, null: false
      t.string   :payer_id, null: false, limit: 64
      t.string   :receiver_id, null: false, limit: 64
      t.string   :order_id, null: false, limit: 64
      t.datetime :order_date, null: false
      t.string   :currency, null: false, limit: 8
      t.integer  :order_total_cents, null: false
      t.string   :authorization_id, limit: 64
      t.datetime :authorization_date
      t.integer  :authorization_total_cents
      t.string   :payment_id, limit: 64
      t.datetime :payment_date
      t.integer  :payment_total_cents
      t.integer  :fee_total_cents
      t.string   :payment_status, null: false, limit: 64
      t.string   :pending_reason, limit: 64

      t.timestamps
    end

    add_index :paypal_payments, :order_id, unique: true
    add_index :paypal_payments, :authorization_id, unique: true
    add_index :paypal_payments, :transaction_id, unique: true
  end
end
