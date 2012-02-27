class CreatePolls < ActiveRecord::Migration
  def self.up
    create_table :polls do |t|
      t.string :title
      t.string :author_id
      t.boolean :active, :default => 1
      t.string :community_id
      t.datetime :closed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :polls
  end
end
