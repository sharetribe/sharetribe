# == Schema Information
#
# Table name: listings
#
#  id                  :integer          not null, primary key
#  author_id           :string(255)
#  category_old        :string(255)
#  title               :string(255)
#  times_viewed        :integer          default(0)
#  language            :string(255)
#  created_at          :datetime
#  updates_email_at    :datetime
#  updated_at          :datetime
#  last_modified       :datetime
#  sort_date           :datetime
#  visibility          :string(255)      default("this_community")
#  listing_type_old    :string(255)
#  description         :text
#  origin              :string(255)
#  destination         :string(255)
#  valid_until         :datetime
#  delta               :boolean          default(TRUE), not null
#  open                :boolean          default(TRUE)
#  share_type_old      :string(255)
#  privacy             :string(255)      default("private")
#  comments_count      :integer          default(0)
#  subcategory_old     :string(255)
#  old_category_id     :integer
#  category_id         :integer
#  share_type_id       :integer
#  transaction_type_id :integer
#  organization_id     :integer
#  price_cents         :integer
#  currency            :string(255)
#  quantity            :string(255)
#
# Indexes
#
#  index_listings_on_category_id          (old_category_id)
#  index_listings_on_listing_type         (listing_type_old)
#  index_listings_on_open                 (open)
#  index_listings_on_share_type_id        (share_type_id)
#  index_listings_on_transaction_type_id  (transaction_type_id)
#  index_listings_on_visibility           (visibility)
#

require 'spec_helper'

describe Listing do

  before(:each) do
    @listing = FactoryGirl.build(:listing)
  end

  it "is valid with valid attributes" do
    @listing.should be_valid
  end

  it "is not valid without a title" do
    @listing.title = nil
    @listing.should_not be_valid
  end

  it "is not valid with a too short title" do
    @listing.title = "a"
    @listing.should_not be_valid
  end

  it "is not valid with a too long title" do
    @listing.title = "0" * 101
    @listing.should_not be_valid
  end

  it "is valid without a description" do
    @listing.description = nil
    @listing.should be_valid
  end

  it "is not valid if description is longer than 5000 characters" do
    @listing.description = "0" * 5001
    @listing.should_not be_valid
  end

  it "is not valid without an author" do
    @listing.author = nil
    @listing.should_not be_valid
  end

  it "is not valid without category" do
    @listing.category = nil
    @listing.should_not be_valid
  end

  it "should not be valid when valid until date is before current date" do
    @listing.valid_until = DateTime.now - 1.day - 1.minute
    @listing.should_not be_valid
  end

  it "should not be valid when valid until is more than one year after current time" do
    @listing.valid_until = DateTime.now + 1.year + 2.days
    @listing.should_not be_valid
  end

  describe "#visible_to?" do
    let(:community) { FactoryGirl.create(:community, private: true) }
    let(:community2) { FactoryGirl.create(:community) }
    let(:person) { FactoryGirl.create(:person, communities: [community, community2]) }
    let(:listing) { FactoryGirl.create(:listing, communities: [community]) }

    it "is not visible, if the listing doesn't belong to the given community" do
      listing.visible_to?(person, community2).should be_falsey
    end

    it "is visible, if user is a member of the given community in which the listing belongs" do
      listing.visible_to?(person, community).should be_truthy
    end

    it "is visible, if user is not logged in and the listing and community are public" do
      community.update_attribute(:private, false)
      listing.update_attribute(:privacy, "public")

      listing.visible_to?(nil, community).should be_truthy
    end

    it "is not visible, if user is not logged in but the listing is private" do
      community.update_attribute(:private, false)
      listing.update_attribute(:privacy, "private")

      listing.visible_to?(nil, community).should be_falsey
    end

    it "is not visible, if user is not logged in but the community is private" do
      community.update_attribute(:private, true)
      listing.update_attribute(:privacy, "public")

      listing.visible_to?(nil, community).should be_falsey
    end

    it "is not visible, if the listing is closed" do
      listing.update_attribute(:open, false)

      listing.visible_to?(person, community).should be_falsey
      listing.visible_to?(nil, community).should be_falsey
    end
  end

  context "with listing type 'offer'" do

    before(:each) do
      @listing.transaction_type = FactoryGirl.create(:transaction_type_give)
    end

    it "should be valid when there is no valid until" do
      @listing.valid_until = nil
      @listing.should be_valid
    end

  end
end
