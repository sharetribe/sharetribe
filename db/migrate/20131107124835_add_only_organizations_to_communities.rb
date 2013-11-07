class AddOnlyOrganizationsToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :only_organizations, :boolean
  end
end
