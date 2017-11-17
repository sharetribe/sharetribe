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

  scope :group_by_start_date, -> { group('DATE(bookings.start_time)') }
  scope :in_period, ->(start_time, end_time) { where(['start_time >= ? AND end_time <= ?', start_time, end_time]) }
  scope :per_day_summary, -> do
    select('DATE(bookings.start_time) AS start_date, SUM(TIMESTAMPDIFF(SECOND, start_time, end_time)) AS day_summary_time')
    .group_by_start_date
  end
  scope :hourly_basis, -> { where(per_hour: true) }

  def week_day
    Listing::WorkingTimeSlot.week_days.keys[start_time.wday].to_sym
  end

  def self.columns
    super.reject { |c| c.name == "end_on_exclusive" }
  end
end
