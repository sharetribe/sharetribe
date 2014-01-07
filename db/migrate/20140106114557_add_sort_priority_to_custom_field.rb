class AddSortPriorityToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :sort_priority, :integer, :after => :type
  end
end
