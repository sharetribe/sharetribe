class AddCustomFieldsTransactionsEmailsIndexes < ActiveRecord::Migration
  def change
    add_index :category_custom_fields, [:category_id, :custom_field_id]

    add_index :transactions, [:starter_id]
    add_index :transactions, [:listing_author_id]

    add_index :emails, [:confirmation_token]
  end
end
