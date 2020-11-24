class AddDeletedToListings < ActiveRecord::Migration
  def change
    add_column :listings, :deleted, :boolean, default: false
  end
end
