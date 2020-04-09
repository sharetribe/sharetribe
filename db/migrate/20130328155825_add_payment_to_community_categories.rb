class AddPaymentToCommunityCategories < ActiveRecord::Migration[5.2]
def up
    add_column :community_categories, :payment, :boolean, :default => false

  end
  
  def down
    remove_column :community_categories, :payment
  end
end
