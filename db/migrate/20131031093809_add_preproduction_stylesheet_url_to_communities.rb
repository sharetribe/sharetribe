class AddPreproductionStylesheetUrlToCommunities < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :preproduction_stylesheet_url, :string
  end
end
