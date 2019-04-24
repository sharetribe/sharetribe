class AddFooterEnabledToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :footer_enabled, :boolean, default: false
  end
end
