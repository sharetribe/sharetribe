class AddIndexesForNewCategorization < ActiveRecord::Migration
  def up
    add_index :transaction_types, :community_id
    add_index :transaction_type_translations, :transaction_type_id
    add_index :transaction_type_translations, [:transaction_type_id, :locale], :name => "locale_index"
    add_index :category_transaction_types, :category_id
    add_index :category_transaction_types, :transaction_type_id

    add_index :custom_field_option_titles, [:custom_field_option_id, :locale], :name => "locale_index"
    add_index :custom_field_names, [:custom_field_id, :locale], :name => "locale_index"

  end

  def down
    remove_index :transaction_types, :community_id
    remove_index :transaction_type_translations, :transaction_type_id
    remove_index :transaction_type_translations, [:transaction_type_id, :locale]
    remove_index :category_transaction_types, :category_id
    remove_index :category_transaction_types, :transaction_type_id

    remove_index :custom_field_option_titles, [:custom_field_option_id, :locale]
    remove_index :custom_field_names, [:custom_field_id, :locale]
  end
end
