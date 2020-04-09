class CreateTestimonials < ActiveRecord::Migration[5.2]
def self.up
    create_table :testimonials do |t|
      t.float :grade
      t.text :text
      t.string :author_id
      t.integer :participation_id

      t.timestamps
    end
  end

  def self.down
    drop_table :testimonials
  end
end
