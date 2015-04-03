class AddUnitTypeToTransaction < ActiveRecord::Migration
  def change
    add_column :listings, :unit_tr_key, :string, limit: 64, after: :unit_type
    add_column :transactions, :unit_type, :string, limit: 32, after: :listing_title
    add_column :transactions, :unit_tr_key, :string, limit: 64, after: :unit_price_currency
  end
end
