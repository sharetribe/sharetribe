class AddShowLocationToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :show_location, :boolean, default: true
  end
end
