class AddHobbyStatusToPeople < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.string :hobby_status, :default => 'Existing'
    end
  end

  def self.down
    change_table :people do |t|
      t.remove :hobby_status
    end
  end
end
