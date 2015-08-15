class RemoveNameFromCommunities < ActiveRecord::Migration
  def up
    remove_column :communities, :name
  end

  def down
    add_column :communities, :name, :string, after: :id
  end
end
