class AddNameTranslationToListingUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :listing_units, :name_tr_key, :string, limit: 64, after: :translation_key
  end
end
