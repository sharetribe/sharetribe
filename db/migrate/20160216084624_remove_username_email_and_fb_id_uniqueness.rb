class RemoveUsernameEmailAndFbIdUniqueness < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up {
        remove_index :people, :username
        remove_index :emails, :address
        remove_index :people, :facebook_id
        add_index :people, :username, unique: false
        add_index :emails, :address, unique: false
        add_index :people, :facebook_id, unique: false
      }
      dir.down {
        remove_index :people, :username
        remove_index :emails, :address
        remove_index :people, :facebook_id
        add_index :people, :username, unique: true
        add_index :emails, :address, unique: true
        add_index :people, :facebook_id, unique: true
      }
    end
  end
end
