class ChangeMemberIdToPersonIdInCommunityMemberships < ActiveRecord::Migration[5.2]
  def self.up
    rename_column(:community_memberships, :member_id, :person_id)
  end

  def self.down
    rename_column(:community_memberships, :person_id, :member_id)
  end
end
