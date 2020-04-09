class AddPrivacyToListings < ActiveRecord::Migration[5.2]
def self.up
    add_column :listings, :privacy, :string, :default => "private"
  end

  def self.down
    remove_column :listings, :privacy
  end
end
