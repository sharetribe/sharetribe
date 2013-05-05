class AddStatusToCommunityMemberships < ActiveRecord::Migration
  def change
    add_column :community_memberships, :status, :string, :null => false, :default => "accepted"
  end
end
