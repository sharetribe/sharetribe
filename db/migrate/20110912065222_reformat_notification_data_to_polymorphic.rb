class ReformatNotificationDataToPolymorphic < ActiveRecord::Migration
  def self.up
    Notification.all.each do |notification|
      if notification.badge_id
        notification.update_attribute(:notifiable_id, notification.badge_id)
        notification.update_attribute(:notifiable_type, "Badge")
      elsif notification.testimonial_id
        notification.update_attribute(:notifiable_id, notification.testimonial_id)
        notification.update_attribute(:notifiable_type, "Testimonial")
      end
    end
  end

  def self.down
  end
end
