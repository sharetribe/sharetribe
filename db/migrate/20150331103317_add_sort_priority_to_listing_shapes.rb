class AddSortPriorityToListingShapes < ActiveRecord::Migration[5.2]
  def change
    add_column :listing_shapes, :sort_priority, :integer, default: 0, null: false, after: :transaction_type_id
  end
end
