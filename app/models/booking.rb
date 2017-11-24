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
#  start_time     :datetime
#  end_time       :datetime
#  per_hour       :boolean          default(FALSE)
#
# Indexes
#
#  index_bookings_on_end_time        (end_time)
#  index_bookings_on_per_hour        (per_hour)
#  index_bookings_on_start_time      (start_time)
#  index_bookings_on_transaction_id  (transaction_id)
#

class Booking < ApplicationRecord
  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id"

  scope :in_period, ->(start_time, end_time) { where(['start_time >= ? AND end_time <= ?', start_time, end_time]) }
  scope :hourly_basis, -> { where(per_hour: true) }
  scope :covers_another_booking, ->(booking) do
    hourly_basis.where(['(start_time <= ? AND end_time > ?) OR (start_time < ? AND end_time >= ?)',
                        booking.start_time, booking.start_time, booking.end_time, booking.end_time])
  end

  def week_day
    Listing::WorkingTimeSlot.week_days.keys[start_time.wday].to_sym
  end

  def self.columns
    super.reject { |c| c.name == "end_on_exclusive" }
  end
end
