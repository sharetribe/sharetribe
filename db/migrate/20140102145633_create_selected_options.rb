class CreateSelectedOptions < ActiveRecord::Migration
  def change
    create_table :selected_options do |t|
      t.belongs_to :custom_field_value
      t.belongs_to :custom_field_options

      t.timestamps
    end
    add_index :selected_options, :custom_field_value_id
  end
end
