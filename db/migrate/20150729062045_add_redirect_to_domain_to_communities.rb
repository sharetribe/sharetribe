class AddRedirectToDomainToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :redirect_to_domain, :boolean, after: :domain, null: false, default: false
  end
end
