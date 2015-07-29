class AddRedirectToDomainToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :redirect_to_domain, :boolean, after: :domain, null: false, default: false
  end
end
