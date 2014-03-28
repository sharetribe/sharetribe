class BadgeNotification < Notification

  belongs_to :badge

  validates_presence_of :badge_id
  validate :person_does_not_already_have_this_notification

  def person_does_not_already_have_this_notification
    existing_notification = BadgeNotification.find_by_receiver_id_and_badge_id(receiver_id, badge_id)
    errors.add(:base, "You have already received this notification.") if existing_notification
  end

end
