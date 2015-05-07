class AddDeletedFlagToListingShape < ActiveRecord::Migration
  def change
    add_column :listing_shapes, :deleted, :boolean, after: :updated_at, default: false
    add_index :listing_shapes, :deleted
  end
end
