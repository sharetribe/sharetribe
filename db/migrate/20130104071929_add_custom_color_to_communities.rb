class AddCustomColorToCommunities < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :custom_color, :string
  end
end
