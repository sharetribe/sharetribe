class AddHobbyStatusToPeople < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.string :hobby_status, :default => Person::HOBBY_STATUSES[:existing]
    end
  end

  def self.down
    change_table :people do |t|
      t.remove :hobby_status
    end
  end
end
