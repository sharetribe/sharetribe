class AddPriceFilterToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :show_price_filter, :boolean
    add_column :communities, :price_filter_min, :int
    add_column :communities, :price_filter_max, :int
  end
end
