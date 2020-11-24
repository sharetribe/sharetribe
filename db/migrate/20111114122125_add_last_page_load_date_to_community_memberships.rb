class AddLastPageLoadDateToCommunityMemberships < ActiveRecord::Migration
  def self.up
    add_column :community_memberships, :last_page_load_date, :datetime
  end

  def self.down
    remove_column :community_memberships, :last_page_load_date
  end
end
