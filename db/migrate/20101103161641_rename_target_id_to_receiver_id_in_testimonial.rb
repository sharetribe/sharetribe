class RenameTargetIdToReceiverIdInTestimonial < ActiveRecord::Migration
  def self.up
    rename_column :testimonials, :target_id, :receiver_id
  end

  def self.down
    rename_column :testimonials, :receiver_id, :target_id
  end
end
