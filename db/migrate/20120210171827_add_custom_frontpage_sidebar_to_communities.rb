class AddCustomFrontpageSidebarToCommunities < ActiveRecord::Migration
  def self.up
    add_column :communities, :custom_frontpage_sidebar, :boolean, :default => 1
  end

  def self.down
    remove_column :communities, :custom_frontpage_sidebar
  end
end
