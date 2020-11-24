require 'spec_helper'

describe Admin2::PaymentSystem::CountryCurrenciesController, type: :controller do
  let(:community) do
    community = FactoryGirl.create(:community, currency: 'USD')
    payment_provision(community, 'paypal')
    payment_provision(community, 'stripe')
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

  context '#update_country_currencies' do
    it 'update currency' do
      expect(community.currency).to eq 'USD'
      patch :update_country_currencies, params: { community: { currency: 'EUR' } }
      community.reload
      expect(community.currency).to eq 'EUR'
    end

    it 'can not update currency' do
      expect(community.currency).to eq 'USD'
      payment_enable(community, 'paypal')
      payment_enable(community, 'stripe')
      patch :update_country_currencies, params: { community: { currency: 'EUR' } }
      community.reload
      expect(community.currency).to eq 'USD'
    end
  end
end
