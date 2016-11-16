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
#
# Indexes
#
#  index_bookings_on_transaction_id  (transaction_id)
#

class Booking < ActiveRecord::Base
  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id"

  def self.columns
    super.reject { |c| c.name == "end_on_exclusive" }
  end
end
