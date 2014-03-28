class Notification < ActiveRecord::Base

  belongs_to :receiver, :class_name => "Person"
  belongs_to :notifiable, :polymorphic => true

  scope :unread, where(:is_read => false)

  VALID_NOTIFIABLE_TYPES = ["Badge", "Comment", "Testimonial", "Listing"]

  validates_presence_of :notifiable_id, :notifiable_type
  validate :person_does_not_already_have_this_notification
  validates_inclusion_of :notifiable_type, :in => VALID_NOTIFIABLE_TYPES

  def person_does_not_already_have_this_notification
    existing_notification = Notification.find_by_receiver_id_and_notifiable_id_and_notifiable_type(receiver_id, notifiable_id, notifiable_type)
    errors.add(:base, "You have already received this notification.") if (existing_notification && existing_notification.id != self.id && existing_notification.created_at > (DateTime.now - 1.day))
  end

end
