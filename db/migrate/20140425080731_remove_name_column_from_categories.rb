class RemoveNameColumnFromCategories < ActiveRecord::Migration
  def up
    remove_column :categories, :name
  end

  def down
    add_column :categories, :name, :string
  end
end
