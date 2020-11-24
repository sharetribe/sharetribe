class AddTargetIdToTestimonial < ActiveRecord::Migration
  def self.up
    add_column :testimonials, :target_id, :string
  end

  def self.down
    remove_column :testimonials, :target_id
  end
end
