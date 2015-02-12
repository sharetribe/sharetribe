class AddShippingFieldsToListing < ActiveRecord::Migration
  def change
    add_column :listings, :require_shipping_address, :boolean, default: false

    #shipping price is initialized in listing.rb to use same currency as price
    add_money :listings, :shipping_price, currency: { present: false }, default: nil
  end
end
