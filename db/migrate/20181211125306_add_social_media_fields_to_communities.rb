class AddSocialMediaFieldsToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :community_customizations, :social_media_title, :string
    add_column :community_customizations, :social_media_description, :text
  end
end
