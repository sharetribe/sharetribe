class CreateComments < ActiveRecord::Migration[5.2]
  def self.up
    create_table :comments do |t|
      t.string :author_id
      t.integer :listing_id
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
