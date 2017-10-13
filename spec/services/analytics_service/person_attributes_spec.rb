require "spec_helper"

describe AnalyticService::PersonAttributes do
  let(:community) { FactoryGirl.create(:community) }
  let(:person) do
    person = FactoryGirl.create(:person, community: community)
    FactoryGirl.create(:community_membership, community: community, person: person, admin: true)
    person
  end

  context "#attributes" do
    it 'not configured community, person' do
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['info_marketplace_ident']).to eq community.ident
      expect(a['admin_created_listing_field']).to eq false
      expect(a['admin_created_listing']).to eq false
      expect(a['admin_invited_user']).to eq false
      expect(a['admin_configured_facebook_connect']).to eq false
      expect(a['admin_configured_outgoing_email']).to eq false
      expect(a['order_type_online_payment']).to eq false
      expect(a['order_type_no_online_payments']).to eq false
      expect(a['admin_configured_paypal_acount']).to eq false
      expect(a['admin_configured_paypal_fees']).to eq false
      expect(a['admin_configured_stripe_api']).to eq false
      expect(a['admin_configured_stripe_fees']).to eq false
      expect(a['payment_providers_available']).to eq 'none'
      expect(a['admin_confirmed_email']).to eq true
      expect(a['admin_deleted_marketplace']).to eq false
    end

    it 'admin created filter' do
      FactoryGirl.create(:custom_field, community: community)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['admin_created_listing_field']).to eq true
    end

    it 'admin created listing' do
      FactoryGirl.create(:listing, community_id: community.id, author: person)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['admin_created_listing']).to eq true
    end

    it 'admin invited user' do
      FactoryGirl.create(:invitation, community_id: community.id, inviter_id: person.id)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['admin_invited_user']).to eq true
    end

    it 'admin configured facebook connect' do
      community.update(facebook_connect_id: '123',
                       facebook_connect_secret: '12345678901234567890123456789012')
      community.save
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['admin_configured_facebook_connect']).to eq true
    end

    it 'admin configured outgoing email' do
      FactoryGirl.create(:marketplace_sender_email, community: community, verification_status: :verified)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['admin_configured_outgoing_email']).to eq true
    end

    it 'order type online payment' do
      transaction_process = FactoryGirl.create(:transaction_process, community_id: community.id)
      FactoryGirl.create(:listing_shape, community_id: community.id,
                                         transaction_process_id: transaction_process.id)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['order_type_online_payment']).to eq true
    end

    it 'order type online payment' do
      transaction_process = FactoryGirl.create(:transaction_process, community_id: community.id, process: 'none')
      FactoryGirl.create(:listing_shape, community_id: community.id,
                                         transaction_process_id: transaction_process.id)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['order_type_no_online_payments']).to eq true
    end

    it 'admin configured paypal acount and fees' do
      FactoryGirl.create(:order_permission, paypal_account: FactoryGirl.create(:paypal_account, community: community))
      FactoryGirl.create(:payment_settings, community_id: community.id, payment_gateway: 'paypal')
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['admin_configured_paypal_acount']).to eq true
      expect(a['admin_configured_paypal_fees']).to eq true
    end

    it 'admin configured stripe api and fees' do
      FeatureFlagService::API::Api.features.enable(community_id: community.id, features: [:stripe])
      FactoryGirl.create(:payment_settings, community_id: community.id, payment_gateway: 'stripe', api_verified: true)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['admin_configured_stripe_api']).to eq true
      expect(a['admin_configured_stripe_fees']).to eq true
    end

    it 'payment providers available' do
      country = ISO3166::Country.find_country_by_name('Finland')
      community.update_columns(country: country.alpha2, currency: country.currency.iso_code)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['payment_providers_available']).to eq 'stripe,paypal'
      country = ISO3166::Country.find_country_by_name('Brasil')
      community.update_columns(country: country.alpha2, currency: country.currency.iso_code)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['payment_providers_available']).to eq 'paypal'
      country = ISO3166::Country.find_country_by_name('Burkina Faso')
      community.update_columns(country: country.alpha2, currency: country.currency.iso_code)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['payment_providers_available']).to eq 'none'
    end

    it 'admin deleted marketplace' do
      community.update_column(:deleted, true)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['admin_deleted_marketplace']).to eq true
      community.update_column(:deleted, false)
      a = AnalyticService::PersonAttributes.new(person: person, community_id: community.id).attributes
      expect(a['admin_deleted_marketplace']).to eq false
    end
  end
end

