class AddCustomColorForMarketplaceDescription < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :description_color, :string, limit: 6, null: true, after: :slogan_color
  end
end
