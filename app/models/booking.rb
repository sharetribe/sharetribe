class Booking < ActiveRecord::Base

  belongs_to :conversation

  attr_accessible :conversation_id, :end_on, :start_on

  def duration
    (end_on - start_on).to_i + 1
  end

end
