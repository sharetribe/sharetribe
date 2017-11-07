class CreateInvitationUnsubscribes < ActiveRecord::Migration[5.1]
  def change
    create_table :invitation_unsubscribes do |t|
      t.integer :community_id
      t.string :email

      t.timestamps
    end
    add_index :invitation_unsubscribes, :community_id
    add_index :invitation_unsubscribes, :email
  end
end
