class AddTypeToCustomFieldValues < ActiveRecord::Migration[5.2]
def change
    add_column :custom_field_values, :type, :string
  end
end
