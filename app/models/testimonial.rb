class Testimonial < ActiveRecord::Base

  GRADES = [
    [ "less_than_expected", { :form_value => "1", :db_value => 0, :default => false } ],
    [ "slightly_less_than_expected", { :form_value => "2", :db_value => 0.25, :default => false } ],
    [ "as_expected", { :form_value => "3", :db_value => 0.5, :default => false } ],
    [ "slightly_better_than_expected", { :form_value => "4", :db_value => 0.75, :default => false } ],
    [ "exceeded_expectations", { :form_value => "5", :db_value => 1, :default => false } ]
  ]

  belongs_to :author, :class_name => "Person", :dependent => :destroy
  belongs_to :receiver, :class_name => "Person", :dependent => :destroy
  belongs_to :participation, :dependent => :destroy

  validates_inclusion_of :grade, :in => 0..1, :allow_nil => false
  
  scope :positive, where("grade >= 0.5")

  # Formats grade so that it can be displayed in the UI
  def displayed_grade
    (grade * 4 + 1).to_i
  end
  
  def notify_receiver(host)
    TestimonialNotification.create(:testimonial_id => id, :receiver_id => receiver.id)
    if receiver.should_receive?("email_about_new_received_testimonials")
      PersonMailer.new_testimonial(self, host).deliver
    end
  end

end
