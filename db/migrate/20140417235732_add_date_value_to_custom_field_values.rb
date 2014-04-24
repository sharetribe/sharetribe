class AddDateValueToCustomFieldValues < ActiveRecord::Migration
  def change
    add_column :custom_field_values, :date_value, :datetime, :after => :numeric_value
  end
end
