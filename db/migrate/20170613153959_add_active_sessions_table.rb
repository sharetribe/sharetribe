class AddActiveSessionsTable < ActiveRecord::Migration
  def up
    create_table :active_sessions, id: false do |t|
      t.string :person_id, limit: 22, null: false
      t.integer :community_id, null: false
      t.datetime :refreshed_at, null: false
      t.timestamps null: false
    end

    execute "ALTER TABLE active_sessions ADD id BINARY(16) FIRST"
    execute "ALTER TABLE active_sessions ADD PRIMARY KEY (id)"

    add_index :active_sessions, :person_id
    add_index :active_sessions, :community_id
    add_index :active_sessions, :refreshed_at
  end

  def down
    drop_table :active_sessions
  end
end
