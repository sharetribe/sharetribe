class AddPriceToCommunityCategories < ActiveRecord::Migration
  def change
    add_column :community_categories, :price, :boolean, :default => false
  end
end
