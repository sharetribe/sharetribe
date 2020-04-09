class RemoveRedirectToDomainFromCommunities < ActiveRecord::Migration[5.2]
def up
    remove_column :communities, :redirect_to_domain
  end

  def down
    add_column :communities, :redirect_to_domain, :boolean, default: false, null: false, after: :domain
  end
end
