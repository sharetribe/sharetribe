class AddConsentToCommunityMemberships < ActiveRecord::Migration[5.2]
def self.up
    add_column :community_memberships, :consent, :string, :default => "KASSI_FI1.0"
  end

  def self.down
    remove_column :community_memberships, :consent
  end
end
