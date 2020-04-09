class AddTargetIdToTestimonial < ActiveRecord::Migration[5.2]
  def self.up
    add_column :testimonials, :target_id, :string
  end

  def self.down
    remove_column :testimonials, :target_id
  end
end
