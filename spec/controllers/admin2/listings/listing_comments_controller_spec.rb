require 'spec_helper'

describe Admin2::Listings::ListingCommentsController, type: :controller do
  let(:community) do
    community = FactoryGirl.create(:community, listing_comments_in_use: false)
    community
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe "#update_listing_comments" do
    it "works" do
      params = { listing_comments_in_use: true }
      expect(community.listing_comments_in_use).to eq false
      put :update_listing_comments, params: { community: params }
      community.reload
      expect(community.listing_comments_in_use).to eq true
    end
  end
end
