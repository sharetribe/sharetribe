class CommunityMembershipNotNullAndUnique < ActiveRecord::Migration
  def up
    change_column :community_memberships, :person_id, :string, null: false
    change_column :community_memberships, :community_id, :integer, null: false

    remove_index :community_memberships, name: "memberships"
    add_index :community_memberships, [:person_id, :community_id], name: "memberships", unique: true
  end

  def down
    change_column :community_memberships, :person_id, :string, null: true
    change_column :community_memberships, :community_id, :integer, null: true

    remove_index :community_memberships, name: "memberships"
    add_index :community_memberships, [:person_id, :community_id], name: "memberships"
  end
end
