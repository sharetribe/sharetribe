class AddListingFieldsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :listing_title, :string, after: :listing_quantity
    add_column :transactions, :listing_author_id, :string, after: :listing_quantity
    add_column :transactions, :unit_price_cents, :integer, after: :listing_title
    add_column :transactions, :unit_price_currency, :string, limit: 8, after: :unit_price_cents
  end
end
