class CreateFollowerRelationships < ActiveRecord::Migration
  def change
    create_table :follower_relationships do |t|
      t.string :person_id, :null => false
      t.string :follower_id, :null => false

      t.timestamps
    end
    
    add_index :follower_relationships, [ :person_id, :follower_id ], :unique => true
    add_index :follower_relationships, :person_id
    add_index :follower_relationships, :follower_id
  end
end
