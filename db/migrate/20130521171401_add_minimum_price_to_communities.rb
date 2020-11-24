class AddMinimumPriceToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :minimum_price_cents, :integer
  end
end
