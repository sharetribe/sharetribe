class AddNameTranslationToListingUnit < ActiveRecord::Migration
  def change
    add_column :listing_units, :name_tr_key, :string, limit: 64, after: :translation_key
  end
end
