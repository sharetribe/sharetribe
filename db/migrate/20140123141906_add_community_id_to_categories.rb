class AddCommunityIdToCategories < ActiveRecord::Migration[5.2]
def change
    add_column :categories, :community_id, :integer
  end
end
