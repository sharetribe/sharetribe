class RemoveVisibilityModel < ActiveRecord::Migration
  def self.up
    drop_table :visibilities
  end

  def self.down
    create_table :visibilities do |t|
      t.integer :visible_object_id
      t.string :visible_object_type
      t.string :is_visible_to, :default => "everybody"

      t.timestamps
    end
  end
end