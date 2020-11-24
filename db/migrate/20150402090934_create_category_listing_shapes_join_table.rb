class CreateCategoryListingShapesJoinTable < ActiveRecord::Migration
  def change
    create_table :category_listing_shapes, id: false do |t|
      t.integer :category_id, null: false
      t.integer :listing_shape_id, null: false
    end

    add_index :category_listing_shapes, :category_id
  end
end
