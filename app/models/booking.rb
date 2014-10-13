# == Schema Information
#
# Table name: bookings
#
#  id             :integer          not null, primary key
#  transaction_id :integer
#  start_on       :date
#  end_on         :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Booking < ActiveRecord::Base

  belongs_to :transaction

  attr_accessible :transaction_id, :end_on, :start_on

  validates :start_on, :end_on, presence: true
  validates_date :start_on, on: :create, on_or_after: :today
  validates_date :end_on, on_or_after: :start_on

  ## TODO REMOVE THIS
  def duration
    (end_on - start_on).to_i + 1
  end

end
