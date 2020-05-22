# == Schema Information
#
# Table name: listings
#
#  id                              :integer          not null, primary key
#  uuid                            :binary(16)       not null
#  community_id                    :integer          not null
#  author_id                       :string(255)
#  category_old                    :string(255)
#  title                           :string(255)
#  times_viewed                    :integer          default(0)
#  language                        :string(255)
#  created_at                      :datetime
#  updates_email_at                :datetime
#  updated_at                      :datetime
#  last_modified                   :datetime
#  sort_date                       :datetime
#  listing_type_old                :string(255)
#  description                     :text(65535)
#  origin                          :string(255)
#  destination                     :string(255)
#  valid_until                     :datetime
#  delta                           :boolean          default(TRUE), not null
#  open                            :boolean          default(TRUE)
#  share_type_old                  :string(255)
#  privacy                         :string(255)      default("private")
#  comments_count                  :integer          default(0)
#  subcategory_old                 :string(255)
#  old_category_id                 :integer
#  category_id                     :integer
#  share_type_id                   :integer
#  listing_shape_id                :integer
#  transaction_process_id          :integer
#  shape_name_tr_key               :string(255)
#  action_button_tr_key            :string(255)
#  price_cents                     :integer
#  currency                        :string(255)
#  quantity                        :string(255)
#  unit_type                       :string(32)
#  quantity_selector               :string(32)
#  unit_tr_key                     :string(64)
#  unit_selector_tr_key            :string(64)
#  deleted                         :boolean          default(FALSE)
#  require_shipping_address        :boolean          default(FALSE)
#  pickup_enabled                  :boolean          default(FALSE)
#  shipping_price_cents            :integer
#  shipping_price_additional_cents :integer
#  availability                    :string(32)       default("none")
#  per_hour_ready                  :boolean          default(FALSE)
#  state                           :string(255)      default("approved")
#  approval_count                  :integer          default(0)
#
# Indexes
#
#  community_author_deleted            (community_id,author_id,deleted)
#  index_listings_on_category_id       (old_category_id)
#  index_listings_on_community_id      (community_id)
#  index_listings_on_listing_shape_id  (listing_shape_id)
#  index_listings_on_new_category_id   (category_id)
#  index_listings_on_open              (open)
#  index_listings_on_state             (state)
#  index_listings_on_uuid              (uuid) UNIQUE
#  index_on_author_id_and_deleted      (author_id,deleted)
#  listings_homepage_query             (community_id,open,state,deleted,valid_until,sort_date)
#  listings_updates_email              (community_id,open,state,deleted,valid_until,updates_email_at,created_at)
#  person_listings                     (community_id,author_id)
#

require 'spec_helper'

describe Listing, type: :model do

  before(:each) do
    @listing = FactoryGirl.build(:listing, listing_shape_id: 123)
  end

  it "is valid with valid attributes" do
    expect(@listing).to be_valid
  end

  it "is not valid without a title" do
    @listing.title = nil
    expect(@listing).not_to be_valid
  end

  it "is not valid with a too short title" do
    @listing.title = "a"
    expect(@listing).not_to be_valid
  end

  it "is not valid with a too long title" do
    @listing.title = "0" * 101
    expect(@listing).not_to be_valid
  end

  it "is valid without a description" do
    @listing.description = nil
    expect(@listing).to be_valid
  end

  it "is not valid if description is longer than 5000 characters" do
    @listing.description = "0" * 5001
    expect(@listing).not_to be_valid
  end

  it "is not valid without an author" do
    @listing.author = nil
    expect(@listing).not_to be_valid
  end

  it "is not valid without category" do
    @listing.category = nil
    expect(@listing).not_to be_valid
  end

  it "should not be valid when valid until date is before current date" do
    @listing.valid_until = DateTime.now - 1.day - 1.minute
    expect(@listing).not_to be_valid
  end

  it "should not be valid when valid until is more than one year after current time" do
    @listing.valid_until = DateTime.now + 1.year + 2.days
    expect(@listing).not_to be_valid
  end

  context "with listing type 'offer'" do

    it "should be valid when there is no valid until" do
      @listing.valid_until = nil
      expect(@listing).to be_valid
    end

  end

  context 'manage availability per hour' do
    let(:community) { FactoryGirl.create(:community) }
    let(:listing) { FactoryGirl.create(:listing, community_id: community.id, listing_shape_id: 123) }

    it '#working_hours_periods_grouped_by_day' do
      listing.working_hours_new_set
      listing.save
      periods = listing.working_hours_periods_grouped_by_day(Time.zone.parse('2017-11-13'), Time.zone.parse('2017-11-19'))
      expect(periods.keys).to eq ["2017-11-13", "2017-11-14", "2017-11-15", "2017-11-16", "2017-11-17"]
      ["2017-11-13", "2017-11-14", "2017-11-15", "2017-11-16", "2017-11-17"].each do |date|
        expect(periods[date].first.start_time.to_s).to eq "#{date} 09:00:00 UTC"
        expect(periods[date].first.end_time.to_s).to eq "#{date} 17:00:00 UTC"
      end
    end
  end

  describe "delete_listings" do
    let(:location) { FactoryGirl.create(:location) }
    let(:hammer) { FactoryGirl.create(:listing, title: "Hammer", listing_shape_id: 123, location: location)}
    let(:author) { hammer.author }

    it "delete_listings by author" do
      # Guard
      expect(hammer.deleted?).to eq(false)

      Listing.delete_by_author(author.id)
      hammer.reload

      expect(hammer.description).to be_nil
      expect(hammer.origin).to be_nil
      expect(hammer.open).to be false
      expect(hammer.location).to be_nil
      expect(hammer.deleted?).to be true
    end
  end

  context 'manage availability per day' do
    let(:community) { FactoryGirl.create(:community) }
    let(:listing) { FactoryGirl.create(:listing, community_id: community.id, listing_shape_id: 123) }
    let(:transaction1) do
      tx = FactoryGirl.create(:transaction, community: community,
                                            listing: listing,
                                            current_state: 'confirmed')
      FactoryGirl.create(:booking, tx: tx, start_on: Date.parse('2020-03-01'), end_on: Date.parse('2020-03-04'))
      tx
    end
    let(:transaction2) do
      tx = FactoryGirl.create(:transaction, community: community,
                                            listing: listing,
                                            current_state: 'confirmed')
      FactoryGirl.create(:booking, tx: tx, start_on: Date.parse('2020-03-05'), end_on: Date.parse('2020-03-06'))
      tx
    end
    let(:listing_blocked_date1) do
      FactoryGirl.create(:listing_blocked_date, listing: listing, blocked_at: Date.parse('2020-03-08'))
    end
    let(:listing_blocked_date2) do
      FactoryGirl.create(:listing_blocked_date, listing: listing, blocked_at: Date.parse('2020-03-28'))
    end

    def expect_booked_dates(listing, start_on, end_on, expected_dates)
      expected = expected_dates.map{ |x| x.to_time(:utc)}.to_set
      result_dates = listing.booked_dates(start_on.to_date, end_on.to_date).to_set
      expect(result_dates).to eq expected
    end

    def expect_direct_blocked_dates(listing, start_on, end_on, expected_dates)
      expected = expected_dates.map{ |x| x.to_time(:utc)}.to_set
      result_dates = listing.direct_blocked_dates(start_on.to_date, end_on.to_date).to_set
      expect(result_dates).to eq expected
    end

    context '#booked_dates' do
      it 'works' do
        transaction1
        transaction2

        expect_booked_dates(listing, '2020-02-27', '2020-03-30', %w(2020-03-01 2020-03-02 2020-03-03 2020-03-05))

        # end is inclusive:
        expect_booked_dates(listing, '2020-03-02', '2020-03-05', %w(2020-03-02 2020-03-03 2020-03-05))
        expect_booked_dates(listing, '2020-02-20', '2020-03-01', %w(2020-03-01))

        expect_booked_dates(listing, '2020-03-04', '2020-03-10', %w(2020-03-05))
        expect_booked_dates(listing, '2020-02-20', '2020-03-02', %w(2020-03-01 2020-03-02))

        expect_booked_dates(listing, '2020-03-06', '2020-03-10', %w())
        expect_booked_dates(listing, '2020-02-20', '2020-02-29', %w())
      end
    end

    context '#direct_blocked_dates' do
      it 'works' do
        listing_blocked_date1
        listing_blocked_date2

        expect_direct_blocked_dates(listing, '2020-02-27', '2020-03-30', %w(2020-03-08 2020-03-28))

        # range is inclusive:
        expect_direct_blocked_dates(listing, '2020-03-08', '2020-03-09', %w(2020-03-08))
        expect_direct_blocked_dates(listing, '2020-03-07', '2020-03-08', %w(2020-03-08))
        expect_direct_blocked_dates(listing, '2020-03-08', '2020-03-08', %w(2020-03-08))
      end
    end
  end
end
