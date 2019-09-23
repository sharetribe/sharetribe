require 'spec_helper'

describe Admin::LandingPageVersionsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:landing_page_version1) { FactoryGirl.create(:landing_page_version, community: community, version: '1') }
  let(:landing_page_version2) { FactoryGirl.create(:landing_page_version, community: community, version: '2') }

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
    FeatureFlagService::API::Api.features.enable(community_id: community.id, features: [:clp_editor])
  end

  describe('#index') do
    it 'shows latest landing page version' do
      landing_page_version1
      landing_page_version2
      get :index
      presenter = assigns(:presenter)
      landing_page_version = presenter.landing_page_version
      expect(landing_page_version.version).to eq 2
    end
  end
end
