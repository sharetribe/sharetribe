class AddCategoryChangeAllowedToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :category_change_allowed, :boolean, :default => false
  end
end
