class AddPrivateCommunityHomepageContentToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :private_community_homepage_content, :text
  end
end
