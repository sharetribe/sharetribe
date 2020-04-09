class RemoveNameColumnFromCategories < ActiveRecord::Migration[5.2]
def up
    remove_column :categories, :name
  end

  def down
    add_column :categories, :name, :string
  end
end
