class AddDomainAliasToCommunities < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :domain_alias, :string
  end
end
