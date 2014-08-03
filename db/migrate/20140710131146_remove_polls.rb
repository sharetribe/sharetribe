class RemovePolls < ActiveRecord::Migration
  def up
    remove_column :communities, :polls_enabled
    drop_table :polls
    drop_table :poll_options
    drop_table :poll_answers
  end

  def down
    create_table :poll_answers do |t|
      t.integer :poll_id
      t.integer :poll_option_id
      t.string :answerer_id
      t.text :comment

      t.timestamps
    end

    create_table :poll_options do |t|
      t.string :label
      t.integer :poll_id
      t.float :percentage

      t.timestamps
    end
    
    create_table :polls do |t|
      t.string :title
      t.string :author_id
      t.boolean :active, :default => 1
      t.string :community_id
      t.datetime :closed_at

      t.timestamps
    end

    add_column :communities, :polls_enabled, :boolean, :default => false
  end
end
