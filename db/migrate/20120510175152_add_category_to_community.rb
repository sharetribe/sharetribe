class AddCategoryToCommunity < ActiveRecord::Migration[5.2]
  def self.up
    add_column :communities, :category, :string, :default => "other"
  end

  def self.down
    remove_column :communities, :category
  end
end
