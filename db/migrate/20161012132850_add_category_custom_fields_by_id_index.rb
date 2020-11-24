class AddCategoryCustomFieldsByIdIndex < ActiveRecord::Migration
  def change
  	add_index :category_custom_fields, [:custom_field_id]
  end
end
