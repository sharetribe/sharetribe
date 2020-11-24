class MonetizeListing < ActiveRecord::Migration
  def change
    add_money :listings, :price, :default => nil
  end
end
