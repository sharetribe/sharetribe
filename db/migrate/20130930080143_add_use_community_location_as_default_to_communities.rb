class AddUseCommunityLocationAsDefaultToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :use_community_location_as_default, :boolean, :default => false
  end
end
