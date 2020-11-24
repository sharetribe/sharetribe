class CreateCustomFieldNames < ActiveRecord::Migration
  def change
    create_table :custom_field_names do |t|
      t.string :value
      t.string :locale
      t.string :custom_field_id

      t.timestamps
    end
  end
end
