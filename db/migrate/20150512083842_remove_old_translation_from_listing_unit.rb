class RemoveOldTranslationFromListingUnit < ActiveRecord::Migration
  def up
    remove_column :listing_units, :translation_key
  end

  def down
    add_column :listing_units, :translation_key, :string, limit: 64, after: :quantity_selector
  end
end
