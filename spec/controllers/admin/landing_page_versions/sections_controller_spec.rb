require 'spec_helper'

describe Admin::LandingPageVersions::SectionsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:landing_page_version) { FactoryGirl.create(:landing_page_version, community: community, version: '1') }

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
    FeatureFlagService::API::Api.features.enable(community_id: community.id, features: [:clp_editor])
  end

  describe '#create' do
    it 'creates section' do
      section_id = 'test1'
      sections = landing_page_version.parsed_content['sections']
      expect(sections.find{|x| x['id'] == section_id}).to eq nil
      post :create, params: { landing_page_version_id: landing_page_version.id,
                              section: {
        kind: 'info',
        variation: 'single_column',
        id: section_id,
        title: 'Shot In the Dark',
        paragraph: 'She only paints with bold colors'
      }}
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      expect(section['kind']).to eq 'info'
      expect(section['variation']).to eq 'single_column'
      expect(section['id']).to eq section_id
      expect(section['title']).to eq 'Shot In the Dark'
      expect(section['paragraph']).to eq 'She only paints with bold colors'
      composition = lpv.parsed_content['composition']
      composition_item = composition.find{|x| x['section']['id'] == section_id}
      expect(composition_item).to_not eq nil
    end

    it 'does not create section with id of existing section' do
      section_id = 'single_info_without_background_and_cta'
      sections = landing_page_version.parsed_content['sections']
      expect(sections.find{|x| x['id'] == section_id}).to_not eq nil
      post :create, params: { landing_page_version_id: landing_page_version.id,
                              section: {
        kind: 'info',
        variation: 'single_column',
        id: section_id,
        title: 'Shot In the Dark',
        paragraph: 'She only paints with bold colors'
      }}
      presenter = assigns(:presenter)
      section = presenter.section
      expect(section.errors.details[:id].first[:error]).to eq :section_with_this_id_already_exists
      expect(section.persisted?).to eq false
    end
  end

  describe '#update' do
    it 'updates section' do
      section_id = 'single_info_without_background_and_cta'
      sections = landing_page_version.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section['title']).to eq "Single column info section without background image and call to action button"
      put :update, params: { landing_page_version_id: landing_page_version.id,
                             id: section_id,
                             section: {
        kind: 'info',
        variation: 'single_column',
        previous_id: section_id,
        id: section_id,
        title: 'Heads Up',
        paragraph: 'I currently have 4 windows open up… and I don’t know why.'
      }}
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      expect(section['kind']).to eq 'info'
      expect(section['variation']).to eq 'single_column'
      expect(section['id']).to eq section_id
      expect(section['title']).to eq 'Heads Up'
      expect(section['paragraph']).to eq 'I currently have 4 windows open up… and I don’t know why.'
    end
  end

  describe '#destroy' do
    it 'destroys section' do
      section_id = 'single_info_without_background_and_cta'
      sections = landing_page_version.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(sections.find{|x| x['id'] == section_id}).to_not eq nil
      composition = landing_page_version.parsed_content['composition']
      composition_item = composition.find{|x| x['section']['id'] == section_id}
      expect(composition_item).to_not eq nil
      delete :destroy, params: {
        landing_page_version_id: landing_page_version.id,
        id: section_id
      }
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to eq nil
      composition = lpv.parsed_content['composition']
      composition_item = composition.find{|x| x['section']['id'] == section_id}
      expect(composition_item).to eq nil
    end
  end
end
