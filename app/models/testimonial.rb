class Testimonial < ActiveRecord::Base

  GRADES = [
    [ "positive", { :form_value => "5", :db_value => 1, :default => false, :icon => "like" } ],
    [ "negative", { :form_value => "1", :db_value => 0, :default => false, :icon => "dislike" } ]
  ]

  belongs_to :author, :class_name => "Person"
  belongs_to :receiver, :class_name => "Person"
  belongs_to :participation

  has_one :notification, :as => :notifiable, :dependent => :destroy

  validates_inclusion_of :grade, :in => 0..1, :allow_nil => false

  scope :positive, where("grade >= 0.5")

  # Formats grade so that it can be displayed in the UI
  def displayed_grade
    (grade * 4 + 1).to_i
  end

  def notify_receiver(community)
    Notification.create(:notifiable_id => id, :notifiable_type => "Testimonial", :receiver_id => receiver.id)
    if receiver.should_receive?("email_about_new_received_testimonials")
      begin
        PersonMailer.new_testimonial(self, community).deliver
      rescue Postmark::InvalidMessageError => e
        # continue exceution if something fails in mailin, but report the issue to AirBrake
        ApplicationHelper.send_error_notification("Error sending email about given feedback", "Email sending error")
      end
    end
  end

end
