class AddStylesheetUrlToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :stylesheet_url, :string
  end
end
