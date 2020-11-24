class AddAboutPageContentToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :about_page_content, :text
  end
end
