class AddStylesheetUrlToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :stylesheet_url, :string
  end
end
