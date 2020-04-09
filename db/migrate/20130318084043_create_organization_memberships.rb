class CreateOrganizationMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_memberships do |t|
      t.string :member_id
      t.integer :organization_id
      t.boolean :admin, :default => false

      t.timestamps
    end
  end
end
