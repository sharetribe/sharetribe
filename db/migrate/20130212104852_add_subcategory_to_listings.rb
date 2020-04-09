class AddSubcategoryToListings < ActiveRecord::Migration[5.2]
def change
    add_column :listings, :subcategory, :string
  end
end
