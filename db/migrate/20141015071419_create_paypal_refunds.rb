class CreatePaypalRefunds < ActiveRecord::Migration
  def change
    create_table :paypal_refunds do |t|
      t.integer :paypal_payment_id
      t.string :currency, limit: 8
      t.integer :payment_total_cents
      t.integer :fee_total_cents
      t.string :refunding_id, limit: 64

      t.timestamps
    end

    add_index :paypal_refunds, :refunding_id, unique: true
  end
end
