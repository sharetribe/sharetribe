class AddCustomHeadScriptToCommunityCustomizations < ActiveRecord::Migration[5.2]
  def change
    add_column :community_customizations, :custom_head_script, :text
  end
end
