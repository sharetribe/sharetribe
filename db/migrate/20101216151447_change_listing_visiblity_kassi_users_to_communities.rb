class ChangeListingVisiblityKassiUsersToCommunities < ActiveRecord::Migration[5.2]
def self.up

  end

  def self.down
    Listing.update_all("visibility = 'kassi_users'", "visibility LIKE 'communities'")
  end
end
