class AddDeviseToPeople < ActiveRecord::Migration
  def self.up
    change_table(:people) do |t|
      #t.database_authenticatable :null => false
      #t.recoverable
      #t.rememberable
      #t.trackable
    
      # t.encryptable
  
  # When updating to Devise 2.0 the old migration needs to be changed, so
##      t.confirmable
# becomes:
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      #t.string   :unconfirmed_email # Only if using reconfirmable
      
      
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable


      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps
    end

    #add_index :people, :email,                :unique => true
    #add_index :people, :reset_password_token, :unique => true
    add_index :people, :confirmation_token,   :unique => true
    # add_index :people, :unlock_token,         :unique => true
    # add_index :people, :authentication_token, :unique => true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    remove_column :people, :confirmation_token
    remove_column :people, :confirmed_at
    remove_column :people, :confirmation_sent_at
    
    remove_index :people, :confirmation_token
  end
end
