class AddIndexesForSendEmails < ActiveRecord::Migration[5.1]
  def change
    add_index :listings, [:community_id, :author_id, :deleted], name: 'community_author_deleted'
    add_index :community_memberships, [:community_id, :person_id, :status], name: 'community_person_status'
    add_index :transactions, [:community_id, :starter_id, :current_state], name: 'community_starter_state'
    add_index :stripe_accounts, :community_id
    add_index :stripe_accounts, :person_id
  end
end
