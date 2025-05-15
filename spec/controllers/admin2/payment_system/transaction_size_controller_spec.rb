require 'spec_helper'

describe Admin2::PaymentSystem::TransactionSizeController, type: :controller do
  let(:community) do
    community = FactoryBot.create(:community)
    payment_provision(community, 'paypal')
    payment_enable(community, 'paypal', commission_from_seller: 11)
    payment_provision(community, 'stripe')
    payment_enable(community, 'stripe', commission_from_seller: 22)
    PaymentSettings.where(payment_gateway: 'paypal').first
      .update_column(:minimum_transaction_fee_cents, 100)
    PaymentSettings.where(payment_gateway: 'stripe').first
      .update_column(:minimum_transaction_fee_cents, 100)
    community
  end
  let(:person) do
    person = FactoryBot.create(:person, community: community, is_admin: true)
    FactoryBot.create(:community_membership, community: community, person: person, admin: true)
    person
  end

  before do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    sign_in_for_spec(person)
  end

  context '#save' do
    it 'update transaction size' do
      patch :save, params: { minimum_listing_price: '1.45' }
      expect(community.minimum_price_cents).to eq 145
    end
  end
end
