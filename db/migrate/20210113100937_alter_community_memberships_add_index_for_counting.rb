class AlterCommunityMembershipsAddIndexForCounting < ActiveRecord::Migration[5.2]
  def change
    add_index :community_memberships, [:community_id, :status]
  end
end
