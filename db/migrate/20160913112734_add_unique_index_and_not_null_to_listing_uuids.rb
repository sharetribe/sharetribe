class AddUniqueIndexAndNotNullToListingUuids < ActiveRecord::Migration
  def change
    change_column_null :listings, :uuid, false
    add_index :listings, :uuid, unique: true
  end
end
