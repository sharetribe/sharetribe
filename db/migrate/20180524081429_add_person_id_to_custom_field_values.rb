class AddPersonIdToCustomFieldValues < ActiveRecord::Migration[5.1]
  def change
    add_column :custom_field_values, :person_id, :string
    add_index :custom_field_values, :person_id
  end
end
