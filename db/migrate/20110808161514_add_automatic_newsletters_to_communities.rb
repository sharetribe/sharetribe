class AddAutomaticNewslettersToCommunities < ActiveRecord::Migration
  def self.up
    add_column :communities, :automatic_newsletters, :boolean, :default => true
  end

  def self.down
    remove_column :communities, :automatic_newsletters
  end
end
