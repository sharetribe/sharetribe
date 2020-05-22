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
    # end_on is inclusive, but booking model query is exclusive on end
    bookings_per_day.in_per_day_period(start_on, end_on + 1.day).each do |booking|
      trimmed_start_on = [booking.start_on, start_on].max
      trimmed_end_on = [booking.end_on - 1.day, end_on].min
      result += (trimmed_start_on..trimmed_end_on).to_a.map{|x| x.to_time(:utc)}
    end
    result
  end
end
