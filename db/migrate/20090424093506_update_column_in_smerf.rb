class UpdateColumnInSmerf < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE smerf_forms MODIFY COLUMN cache LONGTEXT"
  end

  def self.down
    execute "ALTER TABLE smerf_forms MODIFY COLUMN cache TEXT"
  end
end