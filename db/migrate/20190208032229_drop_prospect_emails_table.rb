class DropProspectEmailsTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :prospect_emails
  end

  def down
    create_table :prospect_emails do |t|
      t.string :email
      t.timestamps
    end
  end
end
