class AddShareTypeToListings < ActiveRecord::Migration[5.2]
  def self.up
    add_column :listings, :share_type, :string
  end

  def self.down
    remove_column :listings, :share_type
  end
end
