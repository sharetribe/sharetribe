class AddCustomColorToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :custom_color, :string
  end
end
