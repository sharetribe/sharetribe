class AddPaymentToCommunityCategories < ActiveRecord::Migration
  def up
    add_column :community_categories, :payment, :boolean, :default => false
    CategoriesHelper.add_custom_price_quantity_placeholders
  end
  
  def down
    remove_column :community_categories, :payment
  end
end
