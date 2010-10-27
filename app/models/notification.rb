class Notification < ActiveRecord::Base

  belongs_to :person
  
  scope :unread, where(:is_read => false)

end
