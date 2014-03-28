class PollOption < ActiveRecord::Base

  belongs_to :poll, :dependent => :destroy
  has_many :answers, :class_name => "PollAnswer", :foreign_key => "poll_option_id"

end
