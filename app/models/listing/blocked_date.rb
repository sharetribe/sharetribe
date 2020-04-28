# == Schema Information
#
# Table name: listing_blocked_dates
#
#  id         :bigint           not null, primary key
#  listing_id :bigint
#  blocked_at :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_listing_blocked_dates_on_listing_id                 (listing_id)
#  index_listing_blocked_dates_on_listing_id_and_blocked_at  (listing_id,blocked_at) UNIQUE
#

class Listing::BlockedDate < ApplicationRecord
  belongs_to :listing

  validates :blocked_at, uniqueness: { scope: :listing_id }

  scope :in_period, ->(start_on, end_on) do
    where('blocked_at >= ? AND blocked_at <= ?', start_on, end_on)
  end

  scope :in_period_end_exclusive, ->(start_on, end_on) do
    where('blocked_at >= ? AND blocked_at < ?', start_on, end_on)
  end

  def as_json(options = {})
    super(options.merge(only: [:id, :blocked_at]))
  end
end
