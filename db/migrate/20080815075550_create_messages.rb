class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :sender_id
      t.string :receiver_id
      t.integer :listing_id
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
