class AddPriceQuantityPlaceholderToCommunityCategories < ActiveRecord::Migration
  def change
    add_column :community_categories, :price_quantity_placeholder, :string
  end
end
