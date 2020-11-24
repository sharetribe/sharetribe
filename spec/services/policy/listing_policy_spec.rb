require 'spec_helper'

describe Policy::ListingPolicy do
  describe "#visible?" do
    let(:community) { FactoryGirl.create(:community, private: true) }
    let(:community2) { FactoryGirl.create(:community) }
    let(:person) { FactoryGirl.create(:person, communities: [community]) }
    let(:admin) { FactoryGirl.create(:person, member_of: community, member_is_admin: true) }
    let(:author) { FactoryGirl.create(:person, communities: [community]) }
    let(:listing) do
      FactoryGirl.create(:listing, community_id: community.id,
                                   listing_shape_id: 123, author: author)
    end

    it "is not visible, if the listing doesn't belong to the given community" do
      expect(Policy::ListingPolicy.new(listing, community, person).visible?).to be_truthy
      expect(Policy::ListingPolicy.new(listing, community2, person).visible?).to be_falsey
    end

    it "is visible, if user is a member of the given community in which the listing belongs" do
      expect(Policy::ListingPolicy.new(listing, community, person).visible?).to be_truthy
    end

    it "is visible, if user is not logged in and the listing and community are public" do
      community.update_attribute(:private, false)

      expect(Policy::ListingPolicy.new(listing, community, nil).visible?).to be_truthy
    end

    it "is not visible, if user is not logged in but the community is private" do
      community.update_attribute(:private, true)

      expect(Policy::ListingPolicy.new(listing, community, nil).visible?).to be_falsey
    end

    it "is not visible, if the listing is closed" do
      listing.update_attribute(:open, false)

      expect(Policy::ListingPolicy.new(listing, community, person).visible?).to be_falsey
      expect(Policy::ListingPolicy.new(listing, community, nil).visible?).to be_falsey
    end

    it "is visible to admin if the listing is closed" do
      listing.update_attribute(:open, false)

      expect(Policy::ListingPolicy.new(listing, community, person).visible?).to be_falsey
      expect(Policy::ListingPolicy.new(listing, community, admin).visible?).to be_truthy
    end

    it "is not visible, if the listing is not approved" do
      listing.update_attribute(:state, Listing::APPROVAL_PENDING)

      expect(Policy::ListingPolicy.new(listing, community, person).visible?).to be_falsey
      expect(Policy::ListingPolicy.new(listing, community, nil).visible?).to be_falsey

      listing.update_attribute(:state, Listing::APPROVAL_REJECTED)

      expect(Policy::ListingPolicy.new(listing, community, person).visible?).to be_falsey
      expect(Policy::ListingPolicy.new(listing, community, nil).visible?).to be_falsey
    end

    it "is visible to admin if the listing not approved" do
      listing.update_attribute(:state, Listing::APPROVAL_PENDING)

      expect(Policy::ListingPolicy.new(listing, community, admin).visible?).to be_truthy
    end

    it "is visible to author if the listing not approved" do
      listing.update_attribute(:state, Listing::APPROVAL_PENDING)

      expect(Policy::ListingPolicy.new(listing, community, listing.author).visible?).to be_truthy
    end
  end
end
