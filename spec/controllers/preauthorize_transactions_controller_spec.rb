require 'spec_helper'

describe PreauthorizeTransactionsController, type: :controller do
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
  let(:person2) do
    FactoryGirl.create(:person, member_of: community,
                                given_name: 'Sherry',
                                family_name: 'Rivera',
                                display_name: 'Sky caterpillar'
                      )
  end
  let(:listing1) do
    FactoryGirl.create(:listing, community_id: community.id,
                                 title: 'Apple cake',
                                 author: person1)
  end
  let(:listing2) do
    listing = FactoryGirl.create(:listing, community_id: community.id,
                                           title: 'Cry Wolf',
                                           author: person1,
                                           availability: 'booking',
                                           valid_until: nil)
    listing.working_hours_new_set
    listing.save
    listing
  end
  let(:listing3) do
    FactoryGirl.create(:listing, community_id: community.id,
                                 title: "We will continue to resell web-enabled eProcurement warehouses",
                                 author: person1,
                                 availability: 'booking',
                                 valid_until: nil)
  end
  let(:transaction1) do
    tx = FactoryGirl.create(:transaction, community: community,
                                          listing: listing2,
                                          availability: 'booking',
                                          current_state: 'preauthorized')
    FactoryGirl.create(:booking, tx: tx, start_time: "2050-11-28T09:00:00Z", end_time: "2050-11-28T12:00:00Z", per_hour: true)
    tx
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    sign_in_for_spec(person2)
  end

  describe '#initiated' do
    it 'buy quantity - creates transaction' do
      params = {
        person_id: person2.id,
        listing_id: listing1.id,
        start_on: "", end_on: "",
        message: "", quantity: "1", delivery: "pickup",
        payment_type: "stripe", stripe_payment_method_id: "pm_xXxX",
        locale: "en"
      }

      post :initiated, params: params
      tx = Transaction.last
      expect(tx.listing_id).to eq listing1.id
    end

    it 'buy per hour - creates transaction' do
      params = {
        person_id: person2.id,
        listing_id: listing2.id,
        start_on: "", end_on: "",
        start_time: "2050-11-28T09:00:00Z", end_time: "2050-11-28T12:00:00Z",
        per_hour: "1", message: "", delivery: "pickup",
        payment_type: "stripe", stripe_payment_method_id: "pm_xXxX",
        locale: "en"
      }

      Timecop.travel(Time.zone.parse('2050-11-28 05:00:00')) do
        post :initiated, params: params
        tx = Transaction.last
        expect(tx.listing_id).to eq listing2.id
        booking = tx.booking
        expect(booking).to_not be_nil
        expect(booking.per_hour).to eq true
        expect(booking.start_time).to eq Time.zone.parse("2050-11-28T09:00:00Z")
        expect(booking.end_time).to eq Time.zone.parse("2050-11-28T12:00:00Z")
      end
    end

    it 'buy per day - creates transaction' do
      params = {
        person_id: person2.id,
        listing_id: listing3.id,
        start_on: "2050-11-28", end_on: "2050-11-29",
        message: "",
        payment_type: "stripe", stripe_payment_method_id: "pm_xXxX",
        locale: "en"
      }

      Timecop.travel(Time.zone.parse('2050-11-27 05:00:00')) do
        post :initiated, params: params
        tx = Transaction.last
        expect(tx.listing_id).to eq listing3.id
        booking = tx.booking
        expect(booking).to_not be_nil
        expect(booking.start_on).to eq Date.parse("2050-11-28")
        expect(booking.end_on).to eq Date.parse("2050-11-29")
      end
    end

    it 'buy per hour - does not creates transaction
      if validation after payment failed' do
      params = {
        person_id: person2.id,
        listing_id: listing2.id,
        start_on: "", end_on: "",
        start_time: "2050-11-28T09:00:00Z", end_time: "2050-11-28T12:00:00Z",
        per_hour: "1", message: "", delivery: "pickup",
        payment_type: "stripe", stripe_payment_method_id: "pm_xXxX",
        locale: "en"
      }
      gateway_adapter = double
      allow(gateway_adapter).to receive(:create_payment)
        .and_return(proc do
        # this booking is created during paying
        # this booking is in the equal time slot and transaction state is preauthorized
        transaction1
        TransactionService::Gateway::SyncCompletion.new(Result::Success.new({}))
                    end)
      allow(gateway_adapter).to receive(:reject_payment).and_return(response: Result::Success.new({}))
      allow(TransactionService::Transaction).to receive(:gateway_adapter).and_return(gateway_adapter)
      expect(gateway_adapter).to receive(:reject_payment)

      Timecop.travel(Time.zone.parse('2050-11-28 05:00:00')) do
        expect(Transaction.where(deleted: true).count).to eq 0
        post :initiated, params: params
        expect(Transaction.where(deleted: true).count).to eq 1
      end
    end
  end
end

