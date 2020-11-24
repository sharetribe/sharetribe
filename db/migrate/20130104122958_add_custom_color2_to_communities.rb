class AddCustomColor2ToCommunities < ActiveRecord::Migration
  def up
    rename_column :communities, :custom_color, :custom_color1
    add_column :communities, :custom_color2, :string
  end
  
  def down
    remove_column :communities, :custom_color2
    rename_column :communities, :custom_color1, :custom_color
  end
end
