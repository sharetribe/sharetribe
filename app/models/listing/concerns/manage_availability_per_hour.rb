module ManageAvailabilityPerHour
  extend ActiveSupport::Concern

  def working_hours_listing_schedule
    Biz::Schedule.new do |config|
      config.hours = working_hours_prepare_hash
      config.breaks = {}
      config.holidays = []
      config.time_zone = 'Etc/UTC'
    end
  end

  def working_hours_new_set
    return if working_time_slots.any?
    Listing::WorkingTimeSlot.week_days.keys.each do |week_day|
      next if ['sun', 'sat'].include?(week_day)
      working_time_slots.build(week_day: week_day, from: '09:00', till: '17:00')
    end
  end

  def working_hours_as_json
    as_json(only: [:id, :title],  include: {
      working_time_slots: { only: [:id, :week_day, :from, :till] }
    })
  end

  private

  def working_hours_prepare_hash
    result = {}
    Listing::WorkingTimeSlot.week_days.keys.each do |week_day|
      day = {}
      working_time_slots.by_week_day(week_day).each do |time_slot|
        day[time_slot.from] = time_slot.till
      end
      result[time_slot.week_day] = day
    end
    result
  end

end
