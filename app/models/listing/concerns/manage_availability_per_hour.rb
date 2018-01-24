module ManageAvailabilityPerHour
  extend ActiveSupport::Concern

  def working_hours_new_set(force_create: false)
    return if per_hour_ready
    Listing::WorkingTimeSlot.week_days.keys.each do |week_day|
      next if ['sun', 'sat'].include?(week_day)
      if force_create
        working_time_slots.create(week_day: week_day, from: '09:00', till: '17:00')
        update_column(:per_hour_ready, true) # rubocop:disable Rails/SkipsModelValidations
      else
        working_time_slots.build(week_day: week_day, from: '09:00', till: '17:00')
      end
    end
  end

  def working_hours_as_json
    as_json(only: [:id, :title],  include: {
      working_time_slots: { only: [:id, :week_day, :from, :till] }
    })
  end

  def working_hours_covers_booking?(booking)
    working_time_slots.by_week_day(booking.week_day).each do |time_slot|
      return true if time_slot.covers_booking?(booking)
    end
    false
  end

  def working_hours_periods_grouped_by_day(start_time, end_time)
    working_hours_periods(start_time, end_time).group_by{ |x| x.start_time.to_date.to_s }
  end

  # returns multiple segments per day
  # <Biz::TimeSegment @start_time=2017-11-15 09:00:00 UTC, @end_time=2017-11-15 17:00:00 UTC>
  def working_hours_periods(start_time, end_time)
    if working_time_slots.any?
      working_hours_listing_schedule.periods.after(start_time).timeline.until(end_time).to_a
    else
      []
    end
  end

  private

  def working_hours_prepare_hash
    result = {}
    Listing::WorkingTimeSlot.week_days.keys.each do |week_day|
      day = {}
      working_time_slots.by_week_day(week_day).each do |time_slot|
        day[time_slot.from] = time_slot.till
      end
      result[week_day.to_sym] = day unless day.empty?
    end
    result
  end

  def working_hours_listing_schedule
    @working_hours_listing_schedule ||= Biz::Schedule.new do |config|
      config.hours = working_hours_prepare_hash
      config.breaks = {}
      config.holidays = []
      config.time_zone = 'Etc/UTC'
    end
  end

end
