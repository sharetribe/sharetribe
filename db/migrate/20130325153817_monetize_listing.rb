class MonetizeListing < ActiveRecord::Migration[5.2]
  def change
    add_money :listings, :price, :default => nil
  end
end
