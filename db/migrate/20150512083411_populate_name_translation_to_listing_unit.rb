class PopulateNameTranslationToListingUnit < ActiveRecord::Migration
  def up
    execute("UPDATE listing_units SET name_tr_key = translation_key")
  end

  def down
    execute("UPDATE listing_units SET translation_key = name_tr_key")
  end
end
