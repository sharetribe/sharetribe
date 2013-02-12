class AddSubcategoryToListings < ActiveRecord::Migration
  def change
    add_column :listings, :subcategory, :string
  end
end
