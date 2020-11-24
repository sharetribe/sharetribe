class AddIndexesOnListingsAndAuthTokens < ActiveRecord::Migration[5.1]
  def change
    add_index :listings, [:author_id, :deleted], name: 'index_on_author_id_and_deleted'
    add_index :auth_tokens, [:person_id], name: 'index_on_person_id'
  end
end
