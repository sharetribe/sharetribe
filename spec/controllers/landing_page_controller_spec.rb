require 'spec_helper'

describe LandingPageController, type: :controller do
  render_views

  let(:community) do
    community = FactoryGirl.create(:community, slogan: 'Rain on Your Parade',
                                               description: 'Cup Of Joe')
    customization = community.community_customizations.first
    customization.update_columns(name: 'Lucille',
                                 slogan: 'Rain on Your Parade',
                                 description: 'Cup Of Joe')
    FactoryGirl.create(:landing_page, community_id: community.id)
    FactoryGirl.create(:landing_page_version, community_id: community.id)
    community.reload
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
  end

  after(:each) do
    CustomLandingPage::LandingPageStoreDB::LandingPage.delete_all
    CustomLandingPage::LandingPageStoreDB::LandingPageVersion.delete_all
  end

  describe '#index' do
    it 'renders default title and description' do
      get :index
      expect(response.body).to match('<title>Lucille - Rain on Your Parade</title>')
      expect(response.body).to match('<meta name="description" content="Cup Of Joe" />')
    end

    it 'renders updated meta title and description' do
      community.community_customizations.first.update(
        meta_title: 'SEO Title', meta_description: 'SEO Description',
        social_media_title: 'Social Title', social_media_description: 'Social Description')
      get :index
      expect(response.body).to match('<title>SEO Title</title>')
      expect(response.body).to match('<meta name="description" content="SEO Description" />')
      expect(response.body).to match('<meta property="og:title" content="Social Title" />')
      expect(response.body).to match('<meta property="og:description" content="Social Description" />')
      expect(response.body).to match('<meta name="twitter:title" content="Social Title" />')
      expect(response.body).to match('<meta name="twitter:description" content="Social Description" />')
    end
  end
end
