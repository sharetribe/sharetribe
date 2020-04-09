class AddWelcomeEmailContentToCommunityCustomizations < ActiveRecord::Migration[5.2]
def change
    add_column :community_customizations, :welcome_email_content, :text
  end
end
