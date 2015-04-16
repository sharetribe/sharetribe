class RemoveNullConstraintFromOrderData < ActiveRecord::Migration
  def up
    change_column :paypal_payments, :order_id, :string, limit: 64, null: true
    change_column :paypal_payments, :order_date, :datetime, null: true
    change_column :paypal_payments, :order_total_cents, :integer, null: true
  end

  def down
    change_column :paypal_payments, :order_id, :string, limit: 64, null: false
    change_column :paypal_payments, :order_date, :datetime, null: false
    change_column :paypal_payments, :order_total_cents, :integer, null: false
  end
end
