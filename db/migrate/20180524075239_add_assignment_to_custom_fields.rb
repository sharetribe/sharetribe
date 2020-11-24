class AddAssignmentToCustomFields < ActiveRecord::Migration[5.1]
  def change
    add_column :custom_fields, :assignment, :integer, default: 0
  end
end
