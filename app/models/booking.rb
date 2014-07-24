class Booking < ActiveRecord::Base

  belongs_to :conversation

  attr_accessible :conversation_id, :end_on, :start_on

end
