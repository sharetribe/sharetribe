# == Schema Information
#
# Table name: communities
#
#  id                                         :integer          not null, primary key
#  uuid                                       :binary(16)       not null
#  ident                                      :string(255)
#  domain                                     :string(255)
#  use_domain                                 :boolean          default(FALSE), not null
#  created_at                                 :datetime
#  updated_at                                 :datetime
#  settings                                   :text(65535)
#  consent                                    :string(255)
#  transaction_agreement_in_use               :boolean          default(FALSE)
#  email_admins_about_new_members             :boolean          default(FALSE)
#  use_fb_like                                :boolean          default(FALSE)
#  real_name_required                         :boolean          default(TRUE)
#  automatic_newsletters                      :boolean          default(TRUE)
#  join_with_invite_only                      :boolean          default(FALSE)
#  allowed_emails                             :text(16777215)
#  users_can_invite_new_users                 :boolean          default(TRUE)
#  private                                    :boolean          default(FALSE)
#  label                                      :string(255)
#  show_date_in_listings_list                 :boolean          default(FALSE)
#  all_users_can_add_news                     :boolean          default(TRUE)
#  custom_frontpage_sidebar                   :boolean          default(FALSE)
#  event_feed_enabled                         :boolean          default(TRUE)
#  slogan                                     :string(255)
#  description                                :text(65535)
#  country                                    :string(255)
#  members_count                              :integer          default(0)
#  user_limit                                 :integer
#  monthly_price_in_euros                     :float(24)
#  logo_file_name                             :string(255)
#  logo_content_type                          :string(255)
#  logo_file_size                             :integer
#  logo_updated_at                            :datetime
#  cover_photo_file_name                      :string(255)
#  cover_photo_content_type                   :string(255)
#  cover_photo_file_size                      :integer
#  cover_photo_updated_at                     :datetime
#  small_cover_photo_file_name                :string(255)
#  small_cover_photo_content_type             :string(255)
#  small_cover_photo_file_size                :integer
#  small_cover_photo_updated_at               :datetime
#  custom_color1                              :string(255)
#  custom_color2                              :string(255)
#  slogan_color                               :string(6)
#  description_color                          :string(6)
#  stylesheet_url                             :string(255)
#  stylesheet_needs_recompile                 :boolean          default(FALSE)
#  service_logo_style                         :string(255)      default("full-logo")
#  currency                                   :string(3)        not null
#  facebook_connect_enabled                   :boolean          default(TRUE)
#  minimum_price_cents                        :integer
#  hide_expiration_date                       :boolean          default(TRUE)
#  facebook_connect_id                        :string(255)
#  facebook_connect_secret                    :string(255)
#  google_analytics_key                       :string(255)
#  google_maps_key                            :string(64)
#  name_display_type                          :string(255)      default("first_name_with_initial")
#  twitter_handle                             :string(255)
#  use_community_location_as_default          :boolean          default(FALSE)
#  preproduction_stylesheet_url               :string(255)
#  show_category_in_listing_list              :boolean          default(FALSE)
#  default_browse_view                        :string(255)      default("grid")
#  wide_logo_file_name                        :string(255)
#  wide_logo_content_type                     :string(255)
#  wide_logo_file_size                        :integer
#  wide_logo_updated_at                       :datetime
#  listing_comments_in_use                    :boolean          default(FALSE)
#  show_listing_publishing_date               :boolean          default(FALSE)
#  require_verification_to_post_listings      :boolean          default(FALSE)
#  show_price_filter                          :boolean          default(FALSE)
#  price_filter_min                           :integer          default(0)
#  price_filter_max                           :integer          default(100000)
#  automatic_confirmation_after_days          :integer          default(14)
#  favicon_file_name                          :string(255)
#  favicon_content_type                       :string(255)
#  favicon_file_size                          :integer
#  favicon_updated_at                         :datetime
#  default_min_days_between_community_updates :integer          default(7)
#  listing_location_required                  :boolean          default(FALSE)
#  custom_head_script                         :text(65535)
#  follow_in_use                              :boolean          default(TRUE), not null
#  logo_processing                            :boolean
#  wide_logo_processing                       :boolean
#  cover_photo_processing                     :boolean
#  small_cover_photo_processing               :boolean
#  favicon_processing                         :boolean
#  deleted                                    :boolean
#  end_user_analytics                         :boolean          default(TRUE)
#
# Indexes
#
#  index_communities_on_domain  (domain)
#  index_communities_on_ident   (ident)
#  index_communities_on_uuid    (uuid) UNIQUE
#

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
      expect(shape.name).to eq 'offering-with-online-payment'
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
