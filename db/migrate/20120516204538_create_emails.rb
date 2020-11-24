class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.string :person_id
      t.string :address
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :confirmation_token
    
      t.timestamps
    end
    
    add_index :emails, :address,   :unique => true
  end

  def self.down
    drop_table :emails
  end
end
