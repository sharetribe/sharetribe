class AddCustomFieldValuesTypeIndex < ActiveRecord::Migration[5.2]
def change
    add_index :custom_field_values, :type
  end
end
