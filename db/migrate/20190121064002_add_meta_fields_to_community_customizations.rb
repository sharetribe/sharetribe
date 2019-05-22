class AddMetaFieldsToCommunityCustomizations < ActiveRecord::Migration[5.1]
  def change
    add_column :community_customizations, :meta_title, :string
    add_column :community_customizations, :meta_description, :text
  end
end
