class AddCustomColorForMarketplaceSlogan < ActiveRecord::Migration
  def change
    add_column :communities, :slogan_color, :string, limit: 6, null: true, after: :custom_color2
  end
end
