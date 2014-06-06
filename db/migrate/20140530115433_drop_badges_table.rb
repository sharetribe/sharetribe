class DropBadgesTable < ActiveRecord::Migration
  def up
    drop_table :badges if ActiveRecord::Base.connection.table_exists? 'badges'
  end

  def down
  end
end