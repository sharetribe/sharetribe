require 'spec_helper'

describe TransactionService::StateMachine do
  describe 'Stripe payment intent' do
    let(:listing) do
      listing = FactoryGirl.create(:listing,
                                    availability: :booking,
                                    quantity_selector: 'number')
      listing.working_hours_new_set
      listing.save
      listing
    end
    let(:start_time) { Time.parse('Nov 28, 2050 - 11:00 am') }
    let(:end_time) { Time.parse('Nov 28, 2050 - 2:00 pm') }
    let(:tx) do
      transaction = FactoryGirl.create(:transaction,
                         current_state: :initiated,
                         listing: listing,
                         payment_gateway: 'stripe'
                        )
      FactoryGirl.create(:transaction_transition, to_state: 'initiated', transaction_id: transaction.id, most_recent: true)
      FactoryGirl.create(:booking,
                         tx: transaction,
                         start_on: start_time.to_date, end_on: end_time.to_date,
                         start_time: start_time, end_time: end_time,
                         per_hour: true)
      transaction
    end
    let(:new_booking) { Booking.new(start_time: start_time, end_time: end_time, per_hour: true) }

    it 'customer comply additional action required
      transaction is preauthorized
      booking time slot not available' do
      time = Time.zone.parse("2050-11-28 05:00:00")
      Timecop.travel(time) do
        tx
        expect(booking_available?(new_booking)).to eq true
        TransactionService::StateMachine.transition_to(tx.id, :payment_intent_requires_action)
        expect(booking_available?(new_booking)).to eq false
        TransactionService::StateMachine.transition_to(tx.id, :preauthorized)
      end
      time = Time.zone.parse("2050-11-28 06:00:00")
      Timecop.travel(time) do
        process_jobs
        expect(booking_available?(new_booking)).to eq false
        tx.reload
        expect(tx.current_state).to eq 'preauthorized'
      end
    end

    it 'customer does not complete additional action required
      transaction is expired
      booking time slot is available' do
      time = Time.zone.parse("2050-11-28 05:00:00")
      Timecop.travel(time) do
        tx
        expect(booking_available?(new_booking)).to eq true
        TransactionService::StateMachine.transition_to(tx.id, :payment_intent_requires_action)
        expect(booking_available?(new_booking)).to eq false
      end
      time = Time.zone.parse("2050-11-28 06:00:00")
      Timecop.travel(time) do
        process_jobs
        expect(booking_available?(new_booking)).to eq true
        tx.reload
        expect(tx.current_state).to eq 'payment_intent_action_expired'
      end
    end

    def booking_available?(booking)
      listing.working_hours_covers_booking?(booking) && listing.bookings.covers_another_booking_per_hour(booking).empty?
    end
  end
end
