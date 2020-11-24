class CreatePeople < ActiveRecord::Migration
  
  def self.up
    create_table :people, :id => false do |t|
      t.string :id, :limit => 22, :null => false
      t.integer :coin_amount, :null => false, :default => 0
      t.timestamps
    end
    execute "ALTER TABLE people ADD PRIMARY KEY (id)"
  end

  def self.down
    drop_table :people
  end
end

