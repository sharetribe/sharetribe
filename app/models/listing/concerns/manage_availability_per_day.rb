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
    start_on_t = start_on.is_a?(String) ? start_on.to_date : start_on
    end_on_t = end_on.is_a?(String) ? end_on.to_date : end_on
    result = []
    # end_on is inclusive, but booking model query is exclusive on end
    bookings_per_day.in_per_day_period(start_on_t, end_on_t + 1.day).each do |booking|
      trimmed_start_on_t = [booking.start_on, start_on_t].max
      trimmed_end_on_t = [booking.end_on - 1.day, end_on_t].min
      result += (trimmed_start_on_t..trimmed_end_on_t).to_a.map{|x| x.to_time(:utc)}
    end
    result
  end
end
