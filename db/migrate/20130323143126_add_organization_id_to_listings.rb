class AddOrganizationIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :organization_id, :integer
  end
end
