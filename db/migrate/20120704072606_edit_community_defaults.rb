class EditCommunityDefaults < ActiveRecord::Migration
  def self.up
    change_column_default(:communities, :news_enabled, true)
    change_column_default(:communities, :all_users_can_add_news, true)
    change_column_default(:communities, :custom_frontpage_sidebar, false)
  end

  def self.down
    change_column_default(:communities, :news_enabled, false)
    change_column_default(:communities, :all_users_can_add_news, false)
    change_column_default(:communities, :custom_frontpage_sidebar, true)
  end
end
