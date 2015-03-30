class AddIndexToCommunityTranslations < ActiveRecord::Migration
  def up
    # cache fetches the all translations for given community
    add_index :community_translations, :community_id
    # cache makes these obsolete
    remove_index :community_translations, name: "community_translations_key_locale"
    remove_index :community_translations, name: "community_translations_key"
  end

  def down
    add_index :community_translations, [:community_id, :translation_key, :locale], :name => "community_translations_key_locale"
    add_index :community_translations, [:community_id, :translation_key], :name => "community_translations_key"
  end
end
