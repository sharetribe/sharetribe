class AddIndexesForSendEmails < ActiveRecord::Migration[5.1]
  def change
    add_index :listings, [:community_id, :author_id, :deleted], name: 'person_community_exist'
    add_index :community_memberships, [:community_id, :person_id, :status], name: 'person_community_status'
    add_index :transactions, [:community_id, :starter_id, :current_state], name: 'starter_community_state'
  end
end
