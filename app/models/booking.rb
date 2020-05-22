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
#  index_bookings_on_end_time                              (end_time)
#  index_bookings_on_per_hour                              (per_hour)
#  index_bookings_on_start_time                            (start_time)
#  index_bookings_on_transaction_id                        (transaction_id)
#  index_bookings_on_transaction_start_on_end_on_per_hour  (transaction_id,start_on,end_on,per_hour)
#

class Booking < ApplicationRecord
  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id", inverse_of: :booking

  attr_accessor :skip_validation

  validate :per_day_availability, unless: :skip_validation
  validate :per_hour_availability, unless: :skip_validation

  scope :in_period, ->(start_time, end_time) { where(['start_time >= ? AND end_time <= ?', start_time, end_time]) }
  scope :hourly_basis, -> { where(per_hour: true) }
  scope :covers_another_booking_per_hour, ->(booking) do
    exclude_self(booking)
    .joins(:tx).per_hour_blocked
    .where(['start_time < ? AND end_time > ?', booking.end_time, booking.start_time])
  end
  scope :availability_blocking, -> { merge(Transaction.availability_blocking) }
  scope :per_hour_blocked, -> { hourly_basis.availability_blocking }
  scope :daily_basis, -> { where(per_hour: false) }
  scope :per_day_blocked, -> { daily_basis.availability_blocking }
  scope :in_per_day_period, ->(start_time, end_time) { where(['start_on < ? AND end_on > ?', end_time, start_time]) }
  scope :covers_another_booking_per_day, ->(booking) do
    exclude_self(booking)
    .joins(:tx).per_day_blocked
    .where(['start_on < ? AND end_on > ?', booking.end_on, booking.start_on])
  end
  scope :exclude_self, ->(booking) do
    booking.persisted? ? where.not(id: booking.id) : self
  end

  def week_day
    Listing::WorkingTimeSlot.week_days.keys[start_time.wday].to_sym
  end

  def final_end
    per_hour ? end_time : end_on
  end

  def duration
    if per_hour
      ((end_time - start_time) / 1.hour).to_i
    else
      (end_on - start_on).to_i
    end
  end

  def self.columns
    super.reject { |c| c.name == "end_on_exclusive" }
  end

  def direct_validation
    per_day_availability
    per_hour_availability
  end

  private

  def per_day_availability
    return true if per_hour

    self.class.uncached do
      if tx.listing.bookings.covers_another_booking_per_day(self).any? ||
         tx.listing.blocked_dates.in_period_end_exclusive(self.start_on, self.end_on).any?
        errors.add(:start_on, :invalid)
        errors.add(:end_on, :invalid)
      end
    end
  end

  def per_hour_availability
    return true unless per_hour

    self.class.uncached do
      unless tx.listing.working_hours_covers_booking?(self) &&
             tx.listing.bookings.covers_another_booking_per_hour(self).empty?
        errors.add(:start_time, :invalid)
        errors.add(:end_time, :invalid)
      end
    end
  end
end
