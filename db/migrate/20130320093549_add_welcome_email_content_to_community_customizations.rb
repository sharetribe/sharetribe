class AddWelcomeEmailContentToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :welcome_email_content, :text
  end
end
