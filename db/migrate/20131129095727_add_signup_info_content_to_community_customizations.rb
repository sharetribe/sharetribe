class AddSignupInfoContentToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :signup_info_content, :text
  end
end
