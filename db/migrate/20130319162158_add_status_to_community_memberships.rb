class AddStatusToCommunityMemberships < ActiveRecord::Migration[5.2]
def change
    add_column :community_memberships, :status, :string, :null => false, :default => "accepted"
  end
end
