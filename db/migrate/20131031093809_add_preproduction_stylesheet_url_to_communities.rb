class AddPreproductionStylesheetUrlToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :preproduction_stylesheet_url, :string
  end
end
