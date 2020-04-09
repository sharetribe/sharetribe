class RemoveNameFromCommunities < ActiveRecord::Migration[5.2]
  def up
    remove_column :communities, :name
  end

  def down
    add_column :communities, :name, :string, after: :id
  end
end
