class CreatePersonHobbiesTable < ActiveRecord::Migration
  def self.up
    create_table :person_hobbies, :id => false do |t|
      t.string :person_id
      t.integer :hobby_id

      t.timestamps
    end
  end

  def self.down
    drop table :person_hobbies
  end
end
