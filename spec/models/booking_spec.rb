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

require 'spec_helper'

describe Listing, type: :model do
  let(:community) do
    community = FactoryBot.create(:community)
    FactoryBot.create(:transaction_process, community_id: community.id)
    FactoryBot.create(:payment_settings, community_id: community.id, payment_gateway: 'stripe')
    community
  end
  let(:person1) do
    FactoryBot.create(:person, member_of: community,
                               given_name: 'Florence',
                               family_name: 'Torres',
                               display_name: 'Floryt'
                      )
  end
  let(:listing1) do
    l = FactoryBot.create(:listing, community_id: community.id,
                                    title: "We will continue to resell web-enabled eProcurement warehouses",
                                    author: person1,
                                    availability: 'booking',
                                    valid_until: nil)
    FactoryBot.create(:listing_blocked_date, listing: l, blocked_at: '2050-11-10')
    FactoryBot.create(:listing_blocked_date, listing: l, blocked_at: '2050-11-12')
    l
  end
  let(:listing2) do
    listing = FactoryBot.create(:listing, community_id: community.id,
                                          title: 'Cry Wolf',
                                          author: person1,
                                          valid_until: nil)
    listing.working_hours_new_set
    listing.save
    listing
  end
  let(:booking1) do
    tx = FactoryBot.create(:transaction, community: community,
                                         listing: listing1,
                                         availability: 'booking',
                                         current_state: 'paid')
    FactoryBot.create(:booking, tx: tx, start_on: '2050-11-20', end_on: '2050-11-23')
  end

  let(:booking2) do
    tx = FactoryBot.create(:transaction, community: community,
                                         listing: listing2,
                                         availability: 'booking',
                                         current_state: 'paid')
    FactoryBot.create(:booking, tx: tx,
                                start_time: '2050-11-28 12:00',
                                end_time: '2050-11-28 15:00',
                                per_hour: true)
  end

  describe 'validations' do
    it 'validates per day' do
      booking1
      tx = Transaction.new(community: community, listing: listing1)
      booking = Booking.new(tx: tx, start_on: '2050-11-28', end_on: '2050-11-29')
      expect(booking.valid?).to eq true
      booking = Booking.new(tx: tx, start_on: '2050-11-20', end_on: '2050-11-23')
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_on: '2050-11-21', end_on: '2050-11-29')
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_on: '2050-11-21', end_on: '2050-11-22')
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_on: '2050-11-19', end_on: '2050-11-21')
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_on: '2050-11-23', end_on: '2050-11-29')
      expect(booking.valid?).to eq true
      booking = Booking.new(tx: tx, start_on: '2050-11-18', end_on: '2050-11-20')
      expect(booking.valid?).to eq true
      booking = Booking.new(tx: tx, start_on: '2050-11-18', end_on: '2050-11-25')
      expect(booking.valid?).to eq false

      # Check against blocked dates
      booking = Booking.new(tx: tx, start_on: '2050-11-08', end_on: '2050-11-10')
      expect(booking.valid?).to eq true
      booking = Booking.new(tx: tx, start_on: '2050-11-08', end_on: '2050-11-10')
      expect(booking.valid?).to eq true
      booking = Booking.new(tx: tx, start_on: '2050-11-11', end_on: '2050-11-12')
      expect(booking.valid?).to eq true
      booking = Booking.new(tx: tx, start_on: '2050-11-08', end_on: '2050-11-11')
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_on: '2050-11-08', end_on: '2050-11-13')
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_on: '2050-11-10', end_on: '2050-11-11')
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_on: '2050-11-12', end_on: '2050-11-13')
      expect(booking.valid?).to eq false

      # Both blocked date and booking overlapping
      booking = Booking.new(tx: tx, start_on: '2050-11-11', end_on: '2050-11-22')
      expect(booking.valid?).to eq false
    end

    it 'validates per hour' do
      booking2
      tx = Transaction.new(community: community, listing: listing2)
      booking = Booking.new(tx: tx, start_time: '2050-11-28 09:00', end_time: '2050-11-28 11:00', per_hour: true)
      expect(booking.valid?).to eq true
      booking = Booking.new(tx: tx, start_time: '2050-11-28 12:00', end_time: '2050-11-28 15:00', per_hour: true)
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_time: '2050-11-28 14:00', end_time: '2050-11-28 16:00', per_hour: true)
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_time: '2050-11-28 14:00', end_time: '2050-11-28 13:00', per_hour: true)
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_time: '2050-11-28 11:00', end_time: '2050-11-28 13:00', per_hour: true)
      expect(booking.valid?).to eq false
      booking = Booking.new(tx: tx, start_time: '2050-11-28 11:00', end_time: '2050-11-28 12:00', per_hour: true)
      expect(booking.valid?).to eq true
      booking = Booking.new(tx: tx, start_time: '2050-11-28 15:00', end_time: '2050-11-28 16:00', per_hour: true)
      expect(booking.valid?).to eq true
      booking = Booking.new(tx: tx, start_time: '2050-11-28 11:00', end_time: '2050-11-28 16:00', per_hour: true)
      expect(booking.valid?).to eq false
    end
  end

  describe "per day period" do
    it 'booking overlapping with range' do
      expect(Booking.in_per_day_period('2050-11-19', '2050-11-25')).to eq [booking1]

      expect(Booking.in_per_day_period('2050-11-20', '2050-11-25')).to eq [booking1]
      expect(Booking.in_per_day_period('2050-11-21', '2050-11-25')).to eq [booking1]
      expect(Booking.in_per_day_period('2050-11-22', '2050-11-25')).to eq [booking1]

      expect(Booking.in_per_day_period('2050-11-19', '2050-11-23')).to eq [booking1]
      expect(Booking.in_per_day_period('2050-11-19', '2050-11-22')).to eq [booking1]

      expect(Booking.in_per_day_period('2050-11-21', '2050-11-22')).to eq [booking1]

      expect(Booking.in_per_day_period('2050-11-23', '2050-11-25')).to eq []
      expect(Booking.in_per_day_period('2050-11-19', '2050-11-20')).to eq []
    end
  end
end
