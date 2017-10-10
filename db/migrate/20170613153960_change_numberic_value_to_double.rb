class ChangeNumbericValueToDouble < ActiveRecord::Migration
  def up
    change_column :custom_field_values, :numeric_value, :double
  end

  def down
    change_column :custom_field_values, :numeric_value, :float
  end
end
