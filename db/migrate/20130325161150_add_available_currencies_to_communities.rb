class AddAvailableCurrenciesToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :available_currencies, :text
  end
end
