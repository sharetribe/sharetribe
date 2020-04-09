class CreateCategoryCustomFields < ActiveRecord::Migration[5.2]
  def change
    create_table :category_custom_fields do |t|
      t.belongs_to :category
      t.belongs_to :custom_field
      t.timestamps
    end
  end
end
