class RenameNewCategoryIdAsCategoryIdForListings < ActiveRecord::Migration

  def up
    if column_exists? :listings, :new_category_id
      rename_column :listings, :category_id, :old_category_id
      rename_column :listings, :new_category_id, :category_id
    end
  end

  def down
    if column_exists? :listings, :old_category_id
      rename_column :listings, :category_id, :new_category_id
      rename_column :listings, :old_category_id, :category_id
    end
  end
end
