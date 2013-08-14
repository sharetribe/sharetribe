class AddCustomHeadScriptToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :custom_head_script, :text
  end
end
