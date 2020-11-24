class AddTransactionIdAndNewCategoryIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :transaction_id, :integer, :after => :share_type_id
    add_column :listings, :new_category_id, :integer, :after => :category_id
  end
end
