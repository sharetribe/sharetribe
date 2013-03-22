class RenameMemberIdInOrganizationMemberships < ActiveRecord::Migration
  def change
    rename_column :organization_memberships, :member_id, :person_id
  end
end
