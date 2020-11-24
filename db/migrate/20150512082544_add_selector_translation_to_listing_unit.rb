class AddSelectorTranslationToListingUnit < ActiveRecord::Migration
  def change
    add_column :listing_units, :selector_tr_key, :string, limit: 64, after: :translation_key
  end
end
