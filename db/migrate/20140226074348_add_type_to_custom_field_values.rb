class AddTypeToCustomFieldValues < ActiveRecord::Migration
  def change
    add_column :custom_field_values, :type, :string
  end
end
