class AddDomainAliasToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :domain_alias, :string
  end
end
