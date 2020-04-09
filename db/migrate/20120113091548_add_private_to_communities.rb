class AddPrivateToCommunities < ActiveRecord::Migration[5.2]
def self.up
    add_column :communities, :private, :boolean, :default => 0
  end

  def self.down
    remove_column :communities, :private
  end
end
