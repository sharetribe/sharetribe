class CreateCustomFieldOptions < ActiveRecord::Migration
  def change
    create_table :custom_field_options do |t|
      t.belongs_to :custom_field
      t.integer :sort_priority

      t.timestamps
    end
    add_index :custom_field_options, :custom_field_id
  end
end
