class RemoveConfirmableFromPeople < ActiveRecord::Migration
  # https://github.com/plataformatec/devise/wiki/How-To:-Add-:confirmable-to-Users
  def up
    remove_columns :people, :confirmation_token, :confirmed_at, :confirmation_sent_at
  end

  def down
    add_column :people, :confirmation_token, :string
    add_column :people, :confirmed_at, :datetime
    add_column :people, :confirmation_sent_at, :datetime
    add_index :people, :confirmation_token, :unique => true
    Person.update_all(:confirmed_at => Time.now)
  end
end
