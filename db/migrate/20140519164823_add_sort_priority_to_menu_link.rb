class AddSortPriorityToMenuLink < ActiveRecord::Migration
  def change
    add_column :menu_links, :sort_priority, :int, default: 0
  end
end
