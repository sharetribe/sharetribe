class IncreaseCustomizationLengthLimits < ActiveRecord::Migration
  def up
   change_column :community_customizations, :how_to_use_page_content, :mediumtext
   change_column :community_customizations, :about_page_content, :mediumtext
   change_column :community_customizations, :privacy_page_content, :mediumtext
   change_column :community_customizations, :private_community_homepage_content, :mediumtext
   change_column :community_customizations, :verification_to_post_listings_info_content, :mediumtext
  end

  def down
   change_column :community_customizations, :how_to_use_page_content, :text
   change_column :community_customizations, :about_page_content, :text
   change_column :community_customizations, :privacy_page_content, :text
   change_column :community_customizations, :private_community_homepage_content, :text
   change_column :community_customizations, :verification_to_post_listings_info_content, :text
  end
end
