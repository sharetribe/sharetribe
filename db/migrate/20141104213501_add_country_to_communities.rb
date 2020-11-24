class AddCountryToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :country, :string, :after => :category
  end
end
