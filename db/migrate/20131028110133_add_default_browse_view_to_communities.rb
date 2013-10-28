class AddDefaultBrowseViewToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :default_browse_view, :string, :default => "grid"
  end
end
