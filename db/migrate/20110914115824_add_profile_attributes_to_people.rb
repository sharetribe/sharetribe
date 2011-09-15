class AddProfileAttributesToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :given_name, :string
    add_column :people, :family_name, :string
  end

  def self.down
    remove_column :people, :family_name
    remove_column :people, :given_name
  end
end
