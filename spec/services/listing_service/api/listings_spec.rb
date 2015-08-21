require 'spec_helper'

describe ListingService::API::Listings do

  let(:listings_api) { ListingService::API::Api }
  let(:sell_id) { 111 }
  let(:rent_id) { 112 }
  let(:c2_sell_id) { 212 }
  # TODO We should not use models directly like this
  let(:community) { FactoryGirl.create(:community) }
  let(:community2) { FactoryGirl.create(:community) }

  def create_listing(community, opts = {})
    # TODO We should not use models directly like this
    FactoryGirl.create(:listing, opts.merge(community_id: community.id))
  end

  before(:each) do
    2.times { create_listing(community, listing_shape_id: sell_id) }
    1.times { create_listing(community, listing_shape_id: rent_id) }
    1.times { create_listing(community, listing_shape_id: rent_id, open: false) }
    2.times { create_listing(community2, listing_shape_id: c2_sell_id ) }
  end

  describe "#count" do
    context "success" do
      it "returns count of listing" do
        all_count = listings_api.listings.count(
          community_id: community.id)

        expect(all_count.success).to eq true
        expect(all_count.data).to eq 4

        all_open = listings_api.listings.count(
          community_id: community.id, query: {open: true})

        expect(all_open.success).to eq true
        expect(all_open.data).to eq 3

        sell_count = listings_api.listings.count(
          community_id: community.id, query: { listing_shape_id: sell_id })

        expect(sell_count.success).to eq true
        expect(sell_count.data).to eq 2

        rent_count = listings_api.listings.count(
          community_id: community.id, query: { listing_shape_id: rent_id })

        expect(rent_count.success).to eq true
        expect(rent_count.data).to eq 2

        open_rent_count = listings_api.listings.count(
          community_id: community.id, query: { listing_shape_id: rent_id, open: true })

        expect(open_rent_count.success).to eq true
        expect(open_rent_count.data).to eq 1
      end
    end

    context "failure" do
      it "returns zero, if no match" do
        sell_count = listings_api.listings.count(
          community_id: 8899, query: { listing_shape_id: sell_id })

        rent_count = listings_api.listings.count(
          community_id: community.id, query: { listing_shape_id: 8899 })

        expect(sell_count.success).to eq true
        expect(sell_count.data).to eq 0
        expect(rent_count.success).to eq true
        expect(rent_count.data).to eq 0
      end
    end
  end

  describe "#update" do
    context "success" do
      it "closes listings with specific listing shape" do
        all_open_before = listings_api.listings.count(
          community_id: community.id, query: {open: true}).data

        expect(all_open_before).to eq 3

        listings_api.listings.update_all(
          community_id: community.id,
          query: {listing_shape_id: sell_id},
          opts: {open: false})

        all_open_after = listings_api.listings.count(
          community_id: community.id, query: {open: true}).data

        expect(all_open_after).to eq 1
      end

      it "closes listings in specific community" do
        count_before = listings_api.listings.count(community_id: community.id, query: { open: true }).data
        count2_before = listings_api.listings.count(community_id: community2.id, query: { open: true }).data

        expect(count_before).to eq 3
        expect(count2_before).to eq 2

        listings_api.listings.update_all(
          community_id: community2.id,
          query: {},
          opts: {open: false})

        count_after = listings_api.listings.count(community_id: community.id, query: { open: true }).data
        count2_after = listings_api.listings.count(community_id: community2.id, query: { open: true }).data

        expect(count_after).to eq 3
        expect(count2_after).to eq 0
      end
    end
  end
end
