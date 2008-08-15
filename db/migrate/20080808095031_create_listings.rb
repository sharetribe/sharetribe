class CreateListings < ActiveRecord::Migration
  def self.up
    create_table :listings do |t|
      t.string :author_id
      t.string :category
      t.string :title
      t.text :content
      t.date :good_thru
      t.integer :times_viewed
      t.string :status
      t.integer :value_cc
      t.string :value_other
      t.string :language
      t.string :category
      
      #image,  sent_to_news etc. should be added

      t.timestamps
    end
  end

  def self.down
    drop_table :listings
  end
end
