require 'spec_helper'

describe Listing, type: :model do
  let(:community) do
    community = FactoryGirl.create(:community)
    FactoryGirl.create(:transaction_process, community_id: community.id)
    FactoryGirl.create(:payment_settings, community_id: community.id, payment_gateway: 'stripe')
    community
  end
  let(:person1) do
    FactoryGirl.create(:person, member_of: community,
                                given_name: 'Florence',
                                family_name: 'Torres',
                                display_name: 'Floryt'
                      )
  end
  let(:listing1) do
    l = FactoryGirl.create(:listing, community_id: community.id,
                                     title: "We will continue to resell web-enabled eProcurement warehouses",
                                     author: person1,
                                     availability: 'booking',
                                     valid_until: nil)
    FactoryGirl.create(:listing_blocked_date, listing: l, blocked_at: '2050-11-10')
    FactoryGirl.create(:listing_blocked_date, listing: l, blocked_at: '2050-11-12')
    l
  end
  let(:listing2) do
    listing = FactoryGirl.create(:listing, community_id: community.id,
                                           title: 'Cry Wolf',
                                           author: person1,
                                           valid_until: nil)
    listing.working_hours_new_set
    listing.save
    listing
  end
  let(:booking1) do
    tx = FactoryGirl.create(:transaction, community: community,
                                          listing: listing1,
                                          availability: 'booking',
                                          current_state: 'paid')
    FactoryGirl.create(:booking, tx: tx, start_on: '2050-11-20', end_on: '2050-11-23')
  end

  let(:booking2) do
    tx = FactoryGirl.create(:transaction, community: community,
                                          listing: listing2,
                                          availability: 'booking',
                                          current_state: 'paid')
    FactoryGirl.create(:booking, tx: tx,
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
