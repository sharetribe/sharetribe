class RemoveFaviconUrlFromCommunities < ActiveRecord::Migration[5.2]
def up
    remove_column :communities, :favicon_url
  end

  def down
    add_column :communities, :favicon_url, :string
  end
end
