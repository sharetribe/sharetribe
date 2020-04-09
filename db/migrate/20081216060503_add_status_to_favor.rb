class AddStatusToFavor < ActiveRecord::Migration[5.2]
def self.up
    add_column :favors, :status, :string, :default => "enabled"
  end

  def self.down
    remove_column :favors, :status
  end
end
