class CreateCustomFieldOptions < ActiveRecord::Migration
  def change
    create_table :custom_field_options do |t|
      t.belongs_to :CustomField
      t.integer :sort_priority

      t.timestamps
    end
    add_index :custom_field_options, :CustomField_id
  end
end
