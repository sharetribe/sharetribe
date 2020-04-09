class RenameMemberIdInOrganizationMemberships < ActiveRecord::Migration[5.2]
def change
    rename_column :organization_memberships, :member_id, :person_id
  end
end
