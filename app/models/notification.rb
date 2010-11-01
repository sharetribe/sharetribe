class Notification < ActiveRecord::Base

  belongs_to :receiver, :class_name => "Person"
  
  scope :unread, where(:is_read => false)

end
