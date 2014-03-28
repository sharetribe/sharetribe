class TestimonialNotification < Notification

  belongs_to :testimonial

  validates_presence_of :testimonial_id
  validate :person_does_not_already_have_this_notification

  def person_does_not_already_have_this_notification
    existing_notification = TestimonialNotification.find_by_receiver_id_and_testimonial_id(receiver_id, testimonial_id)
    errors.add(:base, "You have already received this notification.") if existing_notification
  end

end
