class AddClonedFromAndCommunityIdToPeople < ActiveRecord::Migration
  def up
    add_column :people, :cloned_from, :string, { limit: 22 }
    add_index :people, :cloned_from
    add_column :people, :community_id, :integer
  end

  def down
    remove_index :people, :cloned_from
    remove_column :people, :cloned_from
    remove_column :people, :community_id
  end
end
