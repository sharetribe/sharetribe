class AddCustomBodyScriptToCommunity < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :custom_body_script, :text, after: :custom_head_script
    add_column :communities, :custom_css_script, :text, after: :custom_body_script
  end
end
