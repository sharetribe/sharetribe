class AddFieldsToMenuLinks < ActiveRecord::Migration[5.1]
  def change
    add_column :menu_links, :entity_type, :integer, default: 0
  end
end
