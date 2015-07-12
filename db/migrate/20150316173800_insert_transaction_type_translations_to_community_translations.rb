class InsertTransactionTypeTranslationsToCommunityTranslations < ActiveRecord::Migration
  def up
    # Index for basic search for translations
    add_index :community_translations, [:community_id, :translation_key, :locale], :name => "community_translations_key_locale" unless index_exists?(:community_translations, [:community_id, :translation_key, :locale], name: "community_translations_key_locale")
    # Index for admin search for translations
    add_index :community_translations, [:community_id, :translation_key], :name => "community_translations_key" unless index_exists?(:community_translations, [:community_id, :translation_key], name: "community_translations_key")

    # Insert transaction_type_translation.name into the community_translations
    execute("
      INSERT INTO community_translations (community_id, locale, translation_key, translation, created_at, updated_at)
        SELECT transaction_types.community_id AS community_id,
            transaction_type_translations.locale AS locale,
            (SELECT CONCAT('transaction_type_translation.name.', transaction_types.id)) AS translation_key,
            transaction_type_translations.name AS translation,
            transaction_type_translations.created_at AS created_at,
            transaction_type_translations.updated_at AS updated_at
          FROM transaction_type_translations
          LEFT JOIN transaction_types
            ON transaction_types.id = transaction_type_translations.transaction_type_id;")

    # Insert transaction_type_translation.action_button_label into the community_translations
    execute("
      INSERT INTO community_translations (community_id, locale, translation_key, translation, created_at, updated_at)
        SELECT transaction_types.community_id AS community_id,
            transaction_type_translations.locale AS locale,
            (SELECT CONCAT('transaction_type_translation.action_button_label.', transaction_types.id)) AS translation_key,
            transaction_type_translations.action_button_label AS translation,
            transaction_type_translations.created_at AS created_at,
            transaction_type_translations.updated_at AS updated_at
          FROM transaction_type_translations
          LEFT JOIN transaction_types
            ON transaction_types.id = transaction_type_translations.transaction_type_id;")

  end

  def down
    execute("DELETE from community_translations")
  end
end
