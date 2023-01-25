require 'spec_helper'

describe Admin2::PaymentSystem::StripeController, type: :controller do
  let!(:community) do
    community = FactoryGirl.create(:community, currency: 'USD')
    payment_provision(community, 'paypal')
    payment_provision(community, 'stripe')
    community
  end

  let!(:person) do
    person = FactoryGirl.create(:person, community: community, is_admin: true)
    FactoryGirl.create(:community_membership, community: community, person: person, admin: true)
    person
  end

  before do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    sign_in_for_spec(person)
  end

  it 'successfully enabled stripe_connect_onboarding' do
    FeatureFlagHelper.init(community_id: community.id,
                           user_id: nil,
                           request: OpenStruct.new(params: {}, session: {}),
                           is_admin: true,
                           is_marketplace_admin: true)

    patch :onboarding_enable, params: {}
    feature_flag = FeatureFlag.find_by(community_id: community.id, enabled: true, feature: :stripe_connect_onboarding)
    expect(feature_flag.present?).to eq(true)
  end
end
