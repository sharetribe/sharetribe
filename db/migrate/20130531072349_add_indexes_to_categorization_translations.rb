class AddIndexesToCategorizationTranslations < ActiveRecord::Migration
  def change
    add_index :category_translations, [:category_id, :locale], :name => "category_id_with_locale"
    add_index :share_type_translations, [:share_type_id, :locale], :name => "share_type_id_with_locale"
  end
end
