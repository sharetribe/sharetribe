class RemoveClonedFromIndexFromPeople < ActiveRecord::Migration
  def up
    remove_index :people, :cloned_from
  end

  def down
    add_index :people, :cloned_from
  end
end
