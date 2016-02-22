class RemoveUsernameAndEmailUniqueness < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up {
        remove_index :people, :username
        remove_index :emails, :address
        add_index :people, :username, unique: false
        add_index :emails, :address, unique: false
      }
      dir.down {
        remove_index :people, :username
        remove_index :emails, :address
        add_index :people, :username, unique: true
        add_index :emails, :address, unique: true
      }
    end
  end
end
