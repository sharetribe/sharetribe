class AddCommunitySenderEmailsTable < ActiveRecord::Migration
  def up
    create_table :community_sender_emails do |t|
      t.integer :community_id, null: false
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end
  end

  def down
    drop_table :community_sender_emails
  end
end
