require 'spec_helper'

describe Admin::LandingPageVersionsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:landing_page) { FactoryGirl.create(:landing_page, community: community, released_version: '1') }
  let(:landing_page_version1) { FactoryGirl.create(:landing_page_version, community: community, version: '1') }
  let(:landing_page_version2) { FactoryGirl.create(:landing_page_version, community: community, version: '2') }
  let(:plan) do
    {
      expired: false,
      features: {
        whitelabel: true,
        admin_email: true,
        footer: true,
        landing_page: true
      }
    }
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    @request.env[:current_plan] = plan
    user = create_admin_for(community)
    sign_in_for_spec(user)
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

  describe('#release') do
    before(:each) do
      landing_page
      landing_page_version1
      landing_page_version2
    end

    it 'releases current version' do
      expect(LandingPage.released_version(community)).to eq 1
      content = landing_page_version2.parsed_content
      content['something_somewhere'] = 'changed'
      landing_page_version2.update_content(content)
      get :release, params: {id: landing_page_version2.id}
      expect(LandingPage.released_version(community)).to eq 2
    end

    it 'does not releases current version if there are no changes' do
      expect(LandingPage.released_version(community)).to eq 1
      get :release, params: {id: landing_page_version2.id}
      expect(LandingPage.released_version(community)).to eq 1
    end
  end
end
