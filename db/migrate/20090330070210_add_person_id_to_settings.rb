class AddPersonIdToSettings < ActiveRecord::Migration[5.2]
  def self.up
    add_column :settings, :person_id, :string
  end

  def self.down
    remove_column :settings, :person_id
  end
end
