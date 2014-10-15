class RemoveLogoChangeAllowedFromCommunities < ActiveRecord::Migration
  def up
    remove_column :communities, :logo_change_allowed
  end
  def down
    add_column :communities, :logo_change_allowed, :boolean
  end
end
