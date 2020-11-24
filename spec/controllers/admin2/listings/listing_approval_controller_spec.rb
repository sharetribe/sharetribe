require 'spec_helper'

describe Admin2::Listings::ListingApprovalController, type: :controller do
  let(:community) do
    community = FactoryGirl.create(:community, pre_approved_listings: false)
    community
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe "#update_listing_approval" do
    it "works" do
      params = { pre_approved_listings: true }
      expect(community.pre_approved_listings).to eq false
      put :update_listing_approval, params: { community: params }
      community.reload
      expect(community.pre_approved_listings).to eq true
    end
  end
end
