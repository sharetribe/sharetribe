class AddSortPriorityToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :sort_priority, :integer
  end
end