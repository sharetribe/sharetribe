class RemoveLogoChangeAllowedFromCommunities < ActiveRecord::Migration[5.2]
def up
    remove_column :communities, :logo_change_allowed
  end
  def down
    add_column :communities, :logo_change_allowed, :boolean
  end
end
