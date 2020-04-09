class DropBadgesTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :badges if ActiveRecord::Base.connection.table_exists? 'badges'
  end

  def down
  end
end