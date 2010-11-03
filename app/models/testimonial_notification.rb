class TestimonialNotification < Notification
  
  belongs_to :testimonial
  
  validates_presence_of :testimonial_id

end
