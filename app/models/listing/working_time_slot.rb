# == Schema Information
#
# Table name: listing_working_time_slots
#
#  id         :integer          not null, primary key
#  listing_id :integer
#  week_day   :integer
#  from       :string(255)
#  till       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_listing_working_time_slots_on_listing_id  (listing_id)
#

class Listing::WorkingTimeSlot < ApplicationRecord
  belongs_to :listing

  enum week_day: {sun: 0, mon: 1, tue: 2, wed: 3, thu: 4, fri: 5, sat: 6}

  scope :by_week_day, ->(day) { where(week_day: day) }
  scope :ordered, -> { order('listing_working_time_slots.week_day ASC, listing_working_time_slots.from ASC') }


  def covers_booking?(booking)
    start_time = booking.start_time
    year = start_time.year
    month = start_time.month
    day = start_time.day
    from_time = Time.zone.parse("#{year}/#{month}/#{day} #{from}")
    till_time = Time.zone.parse("#{year}/#{month}/#{day} #{till}")
    from_time <= booking.start_time && till_time >= booking.end_time
  end
end
