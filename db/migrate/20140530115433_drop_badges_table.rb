class DropBadgesTable < ActiveRecord::Migration
  def up
    drop_table :badges
  end

  def down
  end
end