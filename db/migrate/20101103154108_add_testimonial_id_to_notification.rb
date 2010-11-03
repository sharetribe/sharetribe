class AddTestimonialIdToNotification < ActiveRecord::Migration
  def self.up
    add_column :notifications, :testimonial_id, :integer
  end

  def self.down
    remove_column :notifications, :testimonial_id
  end
end
