class CreateTablesForCustomCategories < ActiveRecord::Migration
  def up
    create_table :categories do |t|
      t.string :name
      t.integer :parent_id
      t.string :icon
      t.timestamps
    end
    
    # drop old style share types and create new
    drop_table :share_types
    create_table :share_types do |t|
      t.string :name
      t.integer :parent_id
      t.string :icon
      t.timestamps
    end
    
    create_table :category_translations do |t|
      t.integer :category_id
      t.string :locale
      t.string :name
      t.timestamps
    end
    
    create_table :share_type_translations do |t|
      t.integer :share_type_id
      t.string :locale
      t.string :name
      t.timestamps
    end
    
    create_table :community_categories do |t|
      t.integer :community_id
      t.integer :category_id
      t.integer :share_type_id
      t.timestamps
    end
    
    add_index :categories, :name
    add_index :share_types, :name
    add_index :category_translations, :category_id
    add_index :share_type_translations, :share_type_id
    add_index :community_categories, [:community_id, :category_id], :name => "community_categories"
    
  end

  def down
    drop_table :categories
    drop_table :share_types
    # create old style sharetypes
    create_table :share_types do |t|
      t.integer :listing_id
      t.string :name
    end
    drop_table :category_translations
    drop_table :share_type_translations
    drop_table :community_categories
    
  end
end
