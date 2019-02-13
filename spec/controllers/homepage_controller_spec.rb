require 'spec_helper'

describe HomepageController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
  end

  describe '#index' do
    let(:listing) { FactoryGirl.create(:listing, community_id: community.id) }
    let(:pending_listing) do
      FactoryGirl.create(:listing, community_id: community.id,
                                   approval: Listing::APPROVAL_PENDING)
    end

    it 'shows approved listing' do
      listing
      get :index
      listings = assigns(:listings)
      expect(listings.count).to eq 1
    end

    it 'does not show pending listing' do
      pending_listing
      get :index
      listings = assigns(:listings)
      expect(listings.count).to eq 0
    end
  end
end
