class CreateShippingAddress < ActiveRecord::Migration
  def change
    create_table :shipping_addresses do |t|
      t.column :transaction_id, :integer, null: false
      t.column :status, :string
      t.column :name, :string
      t.column :phone, :string
      t.column :postal_code, :string
      t.column :city, :string
      t.column :country, :string
      t.column :state_or_province, :string
      t.column :street1, :string
      t.column :street2, :string

      t.timestamps null: false
    end
  end
end
