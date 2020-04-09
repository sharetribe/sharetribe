class AddOrganizationNameToPeople < ActiveRecord::Migration[5.2]
def change
    add_column :people, :organization_name, :string
  end
end
