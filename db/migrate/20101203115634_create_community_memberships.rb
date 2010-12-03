class CreateCommunityMemberships < ActiveRecord::Migration
  def self.up
    create_table :community_memberships do |t|
      t.string :member_id
      t.integer :community_id
      t.boolean :admin, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :community_memberships
  end
end
