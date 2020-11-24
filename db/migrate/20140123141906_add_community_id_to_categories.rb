class AddCommunityIdToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :community_id, :integer
  end
end
