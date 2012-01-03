class AddDeviseWithoutConfirmableToPeople < ActiveRecord::Migration
  def self.up
    change_table(:people) do |t|
      
        # Add username first and then other devise related stuff.
        t.string :username
        
        t.database_authenticatable :null => true
        t.recoverable
        t.rememberable
        t.trackable
      
        t.encryptable
        #t.confirmable
        # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
        # t.token_authenticatable
    
    
        # Uncomment below if timestamps were not included in your original model.
        # t.timestamps
        
      end

    add_index :people, :username,                :unique => true
    add_index :people, :email,                :unique => true
    add_index :people, :reset_password_token, :unique => true
    #add_index :people, :confirmation_token,   :unique => true
    # add_index :people, :unlock_token,         :unique => true
    # add_index :people, :authentication_token, :unique => true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    #raise ActiveRecord::IrreversibleMigration   
    remove_column :people, :email
    remove_column :people, :encrypted_password
    remove_column :people, :reset_password_token
    remove_column :people, :reset_password_sent_at
    remove_column :people, :remember_created_at
    remove_column :people, :sign_in_count
    remove_column :people, :current_sign_in_at
    remove_column :people, :last_sign_in_at
    remove_column :people, :current_sign_in_ip
    remove_column :people, :last_sign_in_ip
    remove_column :people, :password_salt
    remove_column :people, :username
    

    remove_index :people, :reset_password_token
  end
end
