require 'spec_helper'

describe ListingService::API::Listings do

  let(:listings_api) { ListingService::API::Api }
  let(:sell_id) { 111 }
  let(:rent_id) { 112 }
  # TODO We should not use models directly like this
  let(:community) { FactoryGirl.create(:community) }

  def create_listing(opts = {})
    # TODO We should not use models directly like this
    FactoryGirl.create(:listing, opts.merge(communities: [community]))
  end

  describe "#count" do
    context "success" do
      it "returns count of listing" do
        2.times { create_listing(listing_shape_id: sell_id) }
        1.times { create_listing(listing_shape_id: rent_id) }
        1.times { create_listing(listing_shape_id: rent_id, open: false) }

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
end
