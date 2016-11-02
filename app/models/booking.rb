# == Schema Information
#
# Table name: bookings
#
#  id               :integer          not null, primary key
#  transaction_id   :integer
#  start_on         :date
#  end_on_exclusive :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_bookings_on_transaction_id  (transaction_id)
#

class Booking < ActiveRecord::Base

  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id"

  validates :start_on, :end_on_exclusive, presence: true
  validates_with DateValidator,
                 attribute: :end_on_exclusive,
                 compare_to: :start_on,
                 restriction: :on_or_after

  def self.columns
    super.reject { |c| c.name == "end_on" }
  end

end
