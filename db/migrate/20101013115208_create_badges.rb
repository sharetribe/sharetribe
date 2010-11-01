class CreateBadges < ActiveRecord::Migration
  def self.up
    create_table :badges do |t|
      t.string :person_id
      t.string :name
    end
  end

  def self.down
    drop_table :badges
  end
end
