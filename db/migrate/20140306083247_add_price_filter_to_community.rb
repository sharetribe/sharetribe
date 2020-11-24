class AddPriceFilterToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :show_price_filter, :boolean, :default => false
    add_column :communities, :price_filter_min, :int, :default => 0
    add_column :communities, :price_filter_max, :int, :default => 100000
  end
end
