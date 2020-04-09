class AddMarketplaceSenderEmailsTable < ActiveRecord::Migration[5.2]
def up
    create_table :marketplace_sender_emails do |t|
      t.integer :community_id, null: false
      t.string :name
      t.string :email, null: false

      t.timestamps
    end

    add_index :marketplace_sender_emails, :community_id
  end

  def down
    drop_table :marketplace_sender_emails
  end
end
