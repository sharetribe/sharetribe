class AddAllUsersCanAddNewsToCommunities < ActiveRecord::Migration
  def self.up
    add_column :communities, :all_users_can_add_news, :boolean, :default => 0
  end

  def self.down
    remove_column :communities, :all_users_can_add_news
  end
end
