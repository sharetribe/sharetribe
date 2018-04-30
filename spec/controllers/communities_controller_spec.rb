require 'spec_helper'

describe CommunitiesController, type: :controller do
  render_views

  describe 'Product marketplace' do
    let(:params) do
    {
      admin_email: 'martha@example.com',
      admin_password: '12345678',
      admin_first_name: 'Martha',
      admin_last_name: 'Smith',
      marketplace_name: 'Pearl',
      marketplace_type: 'product',
      marketplace_country: 'FI',
      marketplace_language: 'en',
    }
    end
    subject { post :create, params: params }

    it 'create' do
      expect(Community.where(ident: 'pearl').count).to eq 0
      post :create, params: params
      expect(Community.where(ident: 'pearl').count).to eq 1
      community = Community.where(ident: 'pearl').first
      expect(community.community_customizations.count).to eq 1
      expect(community.categories.count).to eq 1
      expect(community.transaction_processes.count).to eq 3
      expect(community.shapes.count).to eq 2
      configuration = MarketplaceConfigurations.find_by(community_id: community.id)
      expect(configuration.distance_unit).to eq 'metric'
      expect(community.community_memberships.count).to eq 1
      person = Email.where(address: 'martha@example.com').first.person
      expect(person.given_name).to eq 'Martha'
      expect(person.family_name).to eq 'Smith'
      expect(person.username).to eq 'marthas'
      expect(person.locale).to eq 'en'
      membership = community.community_memberships.first
      expect(membership.person).to eq person
      expect(membership.admin).to eq true
      shapes = community.shapes.to_a
      shape = shapes.first
      expect(shape.price_enabled).to eq true
      expect(shape.shipping_enabled).to eq true
      expect(shape.availability).to eq 'none'
      expect(shape.name).to eq 'selling-without-online-payment'
      expect(get_translation(shape, :name_tr_key)).to eq 'Selling without online payment'
      expect(get_translation(shape, :action_button_tr_key)).to eq 'Buy'
      expect(shape.transaction_process.process).to eq :none
      shape = shapes.second
      expect(shape.price_enabled).to eq true
      expect(shape.shipping_enabled).to eq true
      expect(shape.availability).to eq 'none'
      expect(shape.name).to eq 'selling-with-online-payment'
      expect(get_translation(shape, :name_tr_key)).to eq 'Selling with online payment'
      expect(get_translation(shape, :action_button_tr_key)).to eq 'Buy'
      expect(shape.transaction_process.process).to eq :preauthorize
    end

    it 'create USA' do
      expect(Community.where(ident: 'pearl').count).to eq 0
      post :create, params: params.merge(marketplace_country: 'US')
      expect(Community.where(ident: 'pearl').count).to eq 1
      community = Community.where(ident: 'pearl').first
      configuration = MarketplaceConfigurations.find_by(community_id: community.id)
      expect(configuration.distance_unit).to eq 'imperial'
    end

    it 'create and redirect' do
      expect(subject).to redirect_to("http://pearl.lvh.me:9887?auth=#{assigns(:user_token)}")
    end

    it 'create for Services marketplaces' do
      expect(Community.where(ident: 'pearl').count).to eq 0
      post :create, params: params.merge(marketplace_type: 'service')
      expect(Community.where(ident: 'pearl').count).to eq 1
      community = Community.where(ident: 'pearl').first
      expect(community.transaction_processes.count).to eq 3
      expect(community.shapes.count).to eq 2
      shapes = community.shapes.to_a
      shape = shapes.first
      expect(shape.price_enabled).to eq true
      expect(shape.shipping_enabled).to eq false
      expect(shape.availability).to eq 'none'
      expect(shape.name).to eq 'offering-without-online-payment'
      expect(get_translation(shape, :name_tr_key)).to eq 'Offering without online payment'
      expect(get_translation(shape, :action_button_tr_key)).to eq 'Request'
      expect(shape.transaction_process.process).to eq :none
      unit = shape.listing_units.first
      expect(unit.unit_type).to eq 'hour'
      expect(unit.quantity_selector).to eq 'number'
      expect(unit.kind).to eq 'time'
      shape = shapes.second
      expect(shape.price_enabled).to eq true
      expect(shape.shipping_enabled).to eq false
      expect(shape.availability).to eq 'booking'
      expect(shape.name).to eq 'offering-with-online-paymen'
      expect(get_translation(shape, :name_tr_key)).to eq 'Offering with online payment'
      expect(get_translation(shape, :action_button_tr_key)).to eq 'Request'
      expect(shape.transaction_process.process).to eq :preauthorize
      unit = shape.listing_units.first
      expect(unit.unit_type).to eq 'hour'
      expect(unit.quantity_selector).to eq 'number'
      expect(unit.kind).to eq 'time'
    end

    it 'create for Rental marketplaces' do
      expect(Community.where(ident: 'pearl').count).to eq 0
      post :create, params: params.merge(marketplace_type: 'rental')
      expect(Community.where(ident: 'pearl').count).to eq 1
      community = Community.where(ident: 'pearl').first
      expect(community.transaction_processes.count).to eq 3
      expect(community.shapes.count).to eq 2
      shapes = community.shapes.to_a
      shape = shapes.first
      expect(shape.price_enabled).to eq true
      expect(shape.shipping_enabled).to eq false
      expect(shape.availability).to eq 'none'
      expect(shape.name).to eq 'renting-out-without-online-payment'
      expect(get_translation(shape, :name_tr_key)).to eq 'Renting out without online payment'
      expect(get_translation(shape, :action_button_tr_key)).to eq 'Rent'
      expect(shape.transaction_process.process).to eq :none
      unit = shape.listing_units.first
      expect(unit.unit_type).to eq 'day'
      expect(unit.quantity_selector).to eq 'day'
      expect(unit.kind).to eq 'time'
      shape = shapes.second
      expect(shape.price_enabled).to eq true
      expect(shape.shipping_enabled).to eq false
      expect(shape.availability).to eq 'booking'
      expect(shape.name).to eq 'renting-out-with-online-payment'
      expect(get_translation(shape, :name_tr_key)).to eq 'Renting out with online payment'
      expect(get_translation(shape, :action_button_tr_key)).to eq 'Rent'
      expect(shape.transaction_process.process).to eq :preauthorize
      unit = shape.listing_units.first
      expect(unit.unit_type).to eq 'night'
      expect(unit.quantity_selector).to eq 'night'
      expect(unit.kind).to eq 'time'
    end
  end

  def get_translation(shape, property, locale = 'en')
    community_translation = CommunityTranslation.where(
      community_id: shape.community_id,
      locale: locale,
      translation_key: shape.send(property)
    ).first
    community_translation.translation
  end
end
