class RemoveCommunityCategories < ActiveRecord::Migration[5.2]
def up
    drop_table :community_categories
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
