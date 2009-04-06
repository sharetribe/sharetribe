class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups, :id => false do |t|
      t.string :id, :limit => 22, :null => false

      t.timestamps
    end
    execute "ALTER TABLE groups ADD PRIMARY KEY (id)"
  end

  def self.down
    drop_table :groups
  end
end
