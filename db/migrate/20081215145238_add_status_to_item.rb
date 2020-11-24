class AddStatusToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :status, :string, :default => "enabled"
  end

  def self.down
    remove_column :items, :status
  end
end
