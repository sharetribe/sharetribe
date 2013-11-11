class AddLogoChangeAllowedToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :logo_change_allowed, :boolean
  end
end
