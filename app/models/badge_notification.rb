class BadgeNotification < Notification
  
  belongs_to :badge
  
  validates_presence_of :badge_id

end
