class AddCustomFieldValuesTypeIndex < ActiveRecord::Migration
  def change
    add_index :custom_field_values, :type
  end
end
