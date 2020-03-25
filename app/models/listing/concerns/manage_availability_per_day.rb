module ManageAvailabilityPerDay
  extend ActiveSupport::Concern

  def get_blocked_dates(start_on:, end_on:)
    (direct_blocked_dates(start_on, end_on) + booked_dates(start_on, end_on)).uniq
  end

  # returns array of datetime at beginning of day
  def direct_blocked_dates(start_on, end_on)
    blocked_dates.in_period(start_on, end_on).map{|x| x.blocked_at.to_time(:utc)}
  end

  # returns array of datetime at beginning of day
  def booked_dates(start_on, end_on)
    result = []
    bookings_per_day.in_per_day_period(start_on, end_on).each do |booking|
      end_on = booking.end_on - 1.day
      result += (booking.start_on..end_on).to_a.map{|x| x.to_time(:utc)}
    end
    result
  end
end
