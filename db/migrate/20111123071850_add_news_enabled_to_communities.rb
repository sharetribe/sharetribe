class AddNewsEnabledToCommunities < ActiveRecord::Migration[5.2]
  def self.up
    add_column :communities, :news_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :communities, :news_enabled
  end
end
