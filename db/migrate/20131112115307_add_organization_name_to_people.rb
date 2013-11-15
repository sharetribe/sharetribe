class AddOrganizationNameToPeople < ActiveRecord::Migration
  def change
    add_column :people, :organization_name, :string
  end
end
