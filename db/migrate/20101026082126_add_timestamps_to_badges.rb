class AddTimestampsToBadges < ActiveRecord::Migration
  def self.up
    change_table :badges do |t|
      t.timestamps
    end  
  end

  def self.down
    remove_column :badges, :created_at
    remove_column :badges, :updated_at
  end
end
