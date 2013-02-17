class RenameOldCategorizationColumns < ActiveRecord::Migration
  def up
      # This is done in order to not accidentally read the old values anymore, 
      # but to keep them still safe in the DB as backup for a while if bugs found in the news system
      rename_column :listings, :category, :category_old
      rename_column :listings, :subcategory, :subcategory_old
      rename_column :listings, :share_type, :share_type_old
      rename_column :listings, :listing_type, :listing_type_old
    end

    def down
      rename_column :listings, :category_old, :category
      rename_column :listings, :subcategory_old, :subcategory
      rename_column :listings, :share_type_old, :share_type
      rename_column :listings, :listing_type_old, :listing_type
  end
end
