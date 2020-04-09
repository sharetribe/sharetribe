class AddActiveToPeople < ActiveRecord::Migration[5.2]
def self.up
    add_column :people, :active, :boolean, :default => 1
  end

  def self.down
    remove_column :people, :active
  end
end
