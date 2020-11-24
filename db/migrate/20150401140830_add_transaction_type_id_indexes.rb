class AddTransactionTypeIdIndexes < ActiveRecord::Migration
  def change
    add_index :listing_units, :transaction_type_id
    add_index :listing_units, :listing_shape_id
    add_index :listing_shapes, :transaction_type_id
  end
end
