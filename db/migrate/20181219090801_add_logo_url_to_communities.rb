class AddLogoUrlToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :logo_link, :string
  end
end
