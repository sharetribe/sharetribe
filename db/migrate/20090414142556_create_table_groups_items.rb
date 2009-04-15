class CreateTableGroupsItems < ActiveRecord::Migration
  def self.up
    create_table :groups_items, :id => false do |t|
      t.string :group_id
      t.string :item_id
    end
  end

  def self.down
    drop_table :groups_items
  end
end
