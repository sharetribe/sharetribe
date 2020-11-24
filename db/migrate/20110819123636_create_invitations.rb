class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :code
      t.integer :community_id
      t.integer :usages_left
      t.datetime :valid_until
      t.string :information
      # an inviter id could be added, but it's not needed yet so let's leave it to later migration
      
      t.timestamps
    end
    
    add_column :community_memberships, :invitation_id, :integer
  end

  def self.down
    drop_table :invitations
    remove_column :community_memberships, :invitation_id
  end
end
