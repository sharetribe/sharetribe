class AddOrganizationIdToListings < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :organization_id, :integer
  end
end
