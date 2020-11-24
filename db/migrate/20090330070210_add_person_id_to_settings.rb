class AddPersonIdToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :person_id, :string
  end

  def self.down
    remove_column :settings, :person_id
  end
end
