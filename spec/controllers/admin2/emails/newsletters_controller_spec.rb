require 'spec_helper'

describe Admin2::Emails::NewslettersController, type: :controller do
  let(:community) do
    FactoryGirl.create(:community, automatic_newsletters: false,
                                   default_min_days_between_community_updates: 7)
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe "#update_newsletter" do
    it "works" do
      params = { automatic_newsletters: true,
                 default_min_days_between_community_updates: 1 }
      expect(community.automatic_newsletters).to eq false
      expect(community.default_min_days_between_community_updates).to eq 7
      put :update_newsletter, params: { community: params }
      community.reload
      expect(community.automatic_newsletters).to eq true
      expect(community.default_min_days_between_community_updates).to eq 1
    end
  end
end
