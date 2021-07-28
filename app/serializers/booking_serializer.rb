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
#  

class BookingSerializer < ActiveModel::Serializer
    attributes :id, :transaction_id, :start_on, :end_on, :created_at, :updated_at, :start_time, :end_time, :per_hour
end