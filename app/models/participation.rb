class Participation < ActiveRecord::Base

  belongs_to :conversation, :dependent => :destroy, inverse_of: :participations
  belongs_to :person
  has_one :testimonial

  def has_feedback?
    !testimonial.blank?
  end

  # Returns true if there is feedback from person
  def feedback_can_be_given?
    !has_feedback? && !feedback_skipped?
  end

  def send_testimonial_reminder(community)
    if feedback_can_be_given?
      update_attribute(:is_read, false)
      PersonMailer.testimonial_reminder(self, community).deliver
    end
  end

end
