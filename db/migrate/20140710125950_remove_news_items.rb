class RemoveNewsItems < ActiveRecord::Migration
  def self.up
    drop_table :news_items
    remove_column :communities, :news_enabled
  end
  
  def self.down
    add_column :communities, :news_enabled, :boolean, :default => true
    create_table :news_items do |t|
      t.string :title
      t.text :content
      t.integer :community_id
      t.string :author_id

      t.timestamps
    end
  end
end
