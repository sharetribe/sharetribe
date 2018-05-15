# encoding: utf-8
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

describe Community, type: :model do
  let(:community) { FactoryGirl.build(:community) }

  it "is valid with valid attributes" do
    expect(community).to be_valid
  end

  it "is not valid without proper ident" do
    community.ident = "test_community-9"
    expect(community).to be_valid
    community.ident = nil
    expect(community).not_to be_valid
    community.ident = "a"
    expect(community).not_to be_valid
    community.ident = "a" * 51
    expect(community).not_to be_valid
    community.ident = "´?€"
    expect(community).not_to be_valid
  end

  it "validates twitter handle" do
    community.twitter_handle = "abcdefghijkl"
    expect(community).to be_valid
    community.twitter_handle = "abcdefghijklmnopqr"
    expect(community).not_to be_valid
    community.twitter_handle = "@abcd"
    expect(community).not_to be_valid
    community.twitter_handle = "AbCd1"
    expect(community).to be_valid
  end


  describe "#get_new_listings_to_update_email" do

    def get_listing(created_at, updates_email_at)
      FactoryGirl.create(:listing,
        :created_at => created_at.days.ago,
        :updates_email_at => updates_email_at.days.ago,
        :listing_shape_id => 123,
        :community_id => community.id)
    end

    before(:each) do
      @p1 = FactoryGirl.create(:person, :emails => [ FactoryGirl.create(:email, :address => "update_tester@example.com") ])
      @p1.accepted_community = community
      @l1 = get_listing(2,2)
      @l2 = get_listing(3,3)
      @l3 = get_listing(12,12)
      @l4 = get_listing(13,3)
    end

    it "should contain latest and picked listings" do
      listings_to_email = community.get_new_listings_to_update_email(@p1)

      expect(listings_to_email).to include(@l1, @l2, @l4)
      expect(listings_to_email).not_to include(@l3)
    end

    it "should prioritize picked listings" do
      @l5 = get_listing(13,3)
      @l6 = get_listing(13,3)
      @l7 = get_listing(13,3)
      @l8 = get_listing(13,3)
      @l9 = get_listing(13,3)
      @l10 = get_listing(13,3)
      @l11 = get_listing(13,3)
      @l12 = get_listing(13,3)

      listings_to_email = community.get_new_listings_to_update_email(@p1)

      expect(listings_to_email).to include(@l1, @l4, @l5, @l6, @l7, @l8, @l9, @l10, @l11, @l12)
      expect(listings_to_email).not_to include(@l2, @l3)
    end
    it "should order listings using updates_email_at" do
      @l5 = get_listing(13,3)
      @l6 = get_listing(13,4)
      @l7 = get_listing(13,5)
      @l8 = get_listing(13,6)
      @l9 = get_listing(13,6)
      @l10 = get_listing(13,6)
      @l11 = get_listing(13,6)
      @l12 = get_listing(13,6)

      listings_to_email = community.get_new_listings_to_update_email(@p1)

      correct_order = true

      listings_to_email.each_cons(2) do |consecutive_listings|
        first, last = consecutive_listings
        if first.updates_email_at < last.updates_email_at
          correct_order = false
        end
      end

      expect(correct_order).to be_truthy
    end

    it "should include just picked listings" do
      @l5 = get_listing(13,3)
      @l6 = get_listing(13,3)
      @l7 = get_listing(13,3)
      @l8 = get_listing(13,3)
      @l9 = get_listing(13,3)
      @l10 = get_listing(13,3)
      @l11 = get_listing(13,3)
      @l12 = get_listing(13,3)
      @l13 = get_listing(13,3)
      @l14 = get_listing(13,3)

      listings_to_email = community.get_new_listings_to_update_email(@p1)

      expect(listings_to_email).to include(@l4, @l5, @l6, @l7, @l8, @l9, @l10, @l11, @l12, @l13,@l14)
      expect(listings_to_email).not_to include(@l1, @l2, @l3)
    end
  end

  describe '#is_person_only_admin' do
    let(:community1) { FactoryGirl.create(:community) }
    let(:person_admin1) { FactoryGirl.create(:person, member_of: community1, member_is_admin: true) }
    let(:person_admin2) { FactoryGirl.create(:person, member_of: community1, member_is_admin: true) }
    it 'works' do
      person_admin1
      expect(community1.is_person_only_admin(person_admin1)).to eq true
      person_admin2
      expect(community1.is_person_only_admin(person_admin1)).to eq false
    end
  end
end

