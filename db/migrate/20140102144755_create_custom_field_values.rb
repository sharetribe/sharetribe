class CreateCustomFieldValues < ActiveRecord::Migration[5.2]
def change
    create_table :custom_field_values do |t|
      t.belongs_to :custom_field
      t.belongs_to :listing
      t.text :text_value

      t.timestamps
    end
    add_index :custom_field_values, :listing_id
  end
end
