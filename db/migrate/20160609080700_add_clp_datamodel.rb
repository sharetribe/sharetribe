class AddClpDatamodel < ActiveRecord::Migration
  def up
    create_table :landing_pages do |t|
      t.column :community_id, :integer, null: false
      t.column :enabled, :boolean, null: false, default: false
      t.column :released_version, :integer
      t.column :updated_at, :datetime
    end
    add_index :landing_pages, :community_id, unique: true

    create_table :landing_page_versions do |t|
      t.column :community_id, :integer, null: false
      t.column :version, :integer, null: false
      t.column :released, :datetime
      t.column :content, :text, limit: 16.megabytes - 1, null: false
      t.timestamps
    end
    add_index :landing_page_versions, [:community_id, :version], unique: true
  end

  def down
    drop_table :landing_pages
    drop_table :landing_page_versions
  end
end
