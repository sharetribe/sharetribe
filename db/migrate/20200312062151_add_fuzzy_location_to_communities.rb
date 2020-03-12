class AddFuzzyLocationToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :fuzzy_location, :boolean, default: false
  end
end
