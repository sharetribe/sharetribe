class CreatePaymentSettings < ActiveRecord::Migration
  def change
    create_table :payment_settings do |t|
      t.column :active, :boolean, null: false
      t.column :community_id, :integer, null: false
      t.column :payment_gateway, :string, limit: 64
      t.column :payment_process, :string, limit: 64
      t.column :commission_from_seller, :integer
      t.column :minimum_price_cents, :integer
      t.column :confirmation_after_days, :integer, null: false

      t.timestamps
    end

    add_index :payment_settings, :community_id
  end
end
