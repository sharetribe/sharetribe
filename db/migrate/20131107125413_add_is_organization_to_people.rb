class AddIsOrganizationToPeople < ActiveRecord::Migration
  def change
    add_column :people, :is_organization, :boolean
  end
end
