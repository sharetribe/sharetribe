class AddPriceToCommunityCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :community_categories, :price, :boolean, :default => false
  end
end
