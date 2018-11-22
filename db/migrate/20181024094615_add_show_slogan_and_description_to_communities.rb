class AddShowSloganAndDescriptionToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :show_slogan, :boolean, default: true
    add_column :communities, :show_description, :boolean, default: true
  end
end
