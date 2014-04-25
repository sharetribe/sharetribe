class RemoveCommunityCategories < ActiveRecord::Migration
  def up
    drop_table :community_categories
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
