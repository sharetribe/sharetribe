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
  let(:image_file) do
    StringIO.new(Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z/C/HgAGgwJ/lK3Q6wAAAABJRU5ErkJggg=='))
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
  end

  after(:each) do
    RequestStore.clear!
  end

  describe '#index' do
    it 'renders default title and description
      and facebook and twitter image' do
      get :index
      expect(response.body).to match('<title>Lucille - Rain on Your Parade</title>')
      expect(response.body).to match('<meta name="description" content="Cup Of Joe" />')
      expect(response.body).to match('<meta property="og:image" content="landing_page/default_hero_background.jpg" />')
      expect(response.body).to match('<meta name="twitter:image" content="landing_page/default_hero_background.jpg" />')
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

    it 'renders social media logo' do
      community.create_social_logo(image: image_file)
      get :index
      url = community.social_logo.image.url(:original).gsub('?', '\\?')
      expect(response.body).to match("<meta property=\"og:image\" content=\"#{url}\" />")
      expect(response.body).to match("<meta name=\"twitter:image\" content=\"#{url}\" />")
    end
  end
end
