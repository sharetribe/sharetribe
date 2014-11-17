class CreateProspectEmails < ActiveRecord::Migration
  def change
    create_table :prospect_emails do |t|
      t.string :email

      t.timestamps
    end
  end
end
