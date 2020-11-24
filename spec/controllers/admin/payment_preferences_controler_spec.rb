require 'spec_helper'

describe Admin::PaymentPreferencesController, type: :controller do
  let(:community) do
    community = FactoryGirl.create(:community)
    payment_provision(community, 'paypal')
    payment_enable(community, 'paypal', commission_from_seller: 11, minimum_price_cents: 111)
    payment_provision(community, 'stripe')
    payment_enable(community, 'stripe', commission_from_seller: 22, minimum_price_cents: 111)
    PaymentSettings.where(payment_gateway: 'paypal').first
      .update_column(:minimum_transaction_fee_cents, 100)
    PaymentSettings.where(payment_gateway: 'stripe').first
      .update_column(:minimum_transaction_fee_cents, 100)
    community
  end
  let(:person) do
    person = FactoryGirl.create(:person, community: community, is_admin: true)
    FactoryGirl.create(:community_membership, community: community, person: person, admin: true)
    person
  end

  before do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    sign_in_for_spec(person)
  end

  context '#common_update' do
    it 'update general preferences' do
      paypal_setttings = PaymentSettings.where(payment_gateway: 'paypal').first
      stripe_setttings = PaymentSettings.where(payment_gateway: 'stripe').first
      expect(paypal_setttings.commission_from_seller).to eq 11
      expect(paypal_setttings.minimum_price_cents).to eq 111
      expect(paypal_setttings.minimum_transaction_fee_cents).to eq 100
      expect(stripe_setttings.commission_from_seller).to eq 22
      expect(stripe_setttings.minimum_price_cents).to eq 111
      expect(stripe_setttings.minimum_transaction_fee_cents).to eq 100
      post :common_update, params: {payment_preferences_form: {mode: 'general', minimum_listing_price: '1.45'}}
      paypal_setttings.reload
      stripe_setttings.reload
      expect(paypal_setttings.commission_from_seller).to eq 11
      expect(paypal_setttings.minimum_price_cents).to eq 145
      expect(paypal_setttings.minimum_transaction_fee_cents).to eq 100
      expect(stripe_setttings.commission_from_seller).to eq 22
      expect(stripe_setttings.minimum_price_cents).to eq 145
      expect(stripe_setttings.minimum_transaction_fee_cents).to eq 100
    end

    it 'update paypal preferences' do
      paypal_setttings = PaymentSettings.where(payment_gateway: 'paypal').first
      stripe_setttings = PaymentSettings.where(payment_gateway: 'stripe').first
      expect(paypal_setttings.commission_from_seller).to eq 11
      expect(paypal_setttings.minimum_price_cents).to eq 111
      expect(paypal_setttings.minimum_transaction_fee_cents).to eq 100
      expect(stripe_setttings.commission_from_seller).to eq 22
      expect(stripe_setttings.minimum_price_cents).to eq 111
      expect(stripe_setttings.minimum_transaction_fee_cents).to eq 100
      post :common_update, params: {
        payment_preferences_form: {
          mode: 'transaction_fee',
          commission_from_seller: '31',
          minimum_transaction_fee: '0.50'
        },
        gateway: 'paypal'
      }
      paypal_setttings.reload
      stripe_setttings.reload
      expect(paypal_setttings.commission_from_seller).to eq 31
      expect(paypal_setttings.minimum_price_cents).to eq 111
      expect(paypal_setttings.minimum_transaction_fee_cents).to eq 50
      expect(stripe_setttings.commission_from_seller).to eq 22
      expect(stripe_setttings.minimum_price_cents).to eq 111
      expect(stripe_setttings.minimum_transaction_fee_cents).to eq 100
    end

    it 'update stripe preferences' do
      paypal_setttings = PaymentSettings.where(payment_gateway: 'paypal').first
      stripe_setttings = PaymentSettings.where(payment_gateway: 'stripe').first
      expect(paypal_setttings.commission_from_seller).to eq 11
      expect(paypal_setttings.minimum_price_cents).to eq 111
      expect(paypal_setttings.minimum_transaction_fee_cents).to eq 100
      expect(stripe_setttings.commission_from_seller).to eq 22
      expect(stripe_setttings.minimum_price_cents).to eq 111
      expect(stripe_setttings.minimum_transaction_fee_cents).to eq 100
      post :common_update, params: {
        payment_preferences_form: {
          mode: 'transaction_fee',
          commission_from_seller: '23',
          minimum_transaction_fee: '0.50'
        },
        gateway: 'stripe'
      }
      paypal_setttings.reload
      stripe_setttings.reload
      expect(paypal_setttings.commission_from_seller).to eq 11
      expect(paypal_setttings.minimum_price_cents).to eq 111
      expect(paypal_setttings.minimum_transaction_fee_cents).to eq 100
      expect(stripe_setttings.commission_from_seller).to eq 23
      expect(stripe_setttings.minimum_price_cents).to eq 111
      expect(stripe_setttings.minimum_transaction_fee_cents).to eq 50
    end
  end
end
