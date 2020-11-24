class AddLabelToCommunities < ActiveRecord::Migration
  def self.up
    add_column :communities, :label, :string
  end

  def self.down
    remove_column :communities, :label
  end
end
