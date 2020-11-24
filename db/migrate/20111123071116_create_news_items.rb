class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.string :title
      t.string :content
      t.integer :community_id
      t.string :author_id

      t.timestamps
    end
  end

  def self.down
    drop_table :news_items
  end
end
