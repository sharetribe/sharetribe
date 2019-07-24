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

  describe 'hero' do
    describe '#update' do
      it 'works' do
        section_id = 'hero'
        put :update, params: { landing_page_version_id: landing_page_version.id,
                               id: section_id,
                               section: {
            kind: 'hero',
            id: 'hero',
            previous_id: 'hero',
            background_image_variation: 'light'
        }}
        lpv = LandingPageVersion.find(landing_page_version.id)
        sections = lpv.parsed_content['sections']
        section = sections.find{|x| x['id'] == section_id}
        expect(section['background_image_variation']).to eq 'light'
      end
    end

    describe '#update of existing section' do
      it 'keeps existing attrs as is' do
        existing_hero_sample = {
          "id": "hero",
          "kind": "hero",
          "variation": { "type": "marketplace_data", "id": "search_type" },
          "title": { "type": "marketplace_data", "id": "slogan" },
          "subtitle": { "type": "marketplace_data", "id": "description" },
          "background_image": { "type": "assets", "id": "hero_background_image" },
          "background_image_variation": "dark",
          "search_button": { "type": "translation", "id": "search_button" },
          "search_path": { "type": "path", "id": "search" },
          "search_placeholder": { "type": "marketplace_data", "id": "search_placeholder"},
          "search_location_with_keyword_placeholder": { "type": "marketplace_data",  "id": "search_location_with_keyword_placeholder" },
          "signup_path": { "type": "path", "id": "signup" },
          "signup_button": { "type": "translation", "id": "signup_button" },
          "search_button_color": { "type": "marketplace_data", "id": "primary_color" },
          "search_button_color_hover": { "type": "marketplace_data", "id": "primary_color_darken" },
          "signup_button_color": { "type": "marketplace_data", "id": "primary_color" },
          "signup_button_color_hover": { "type": "marketplace_data", "id": "primary_color_darken" }
        }

        e_lpv = landing_page_version
        sections = e_lpv.parsed_content['sections'].select{|s| s['id'] != 'hero'}
        sections << existing_hero_sample
        e_lpv.parsed_content['sections'] = sections
        e_lpv.update_content(e_lpv.parsed_content)

        section_id = 'hero'
        put :update, params: { landing_page_version_id: e_lpv.id,
                               id: section_id,
                               section: {
            kind: 'hero',
            id: 'hero',
            previous_id: 'hero',
            background_image_variation: 'light'
        }}
        lpv = LandingPageVersion.find(e_lpv.id)
        sections = lpv.parsed_content['sections']
        section = sections.find{|x| x['id'] == section_id}
        expect(section['background_image_variation']).to eq 'light'

        existing_bg_image = { "type" => "assets", "id" => "hero_background_image" }
        expect(section['background_image']).to eq existing_bg_image
      end
    end
  end

  describe 'footer' do
    describe '#update' do
      it 'works' do
        section_id = 'footer'
        put :update, params: { landing_page_version_id: landing_page_version.id,
                               id: section_id,
                               section: {
          id: 'footer',
          kind: 'footer',
          theme: 'marketplace_color',
          previous_id: 'footer',
          copyright: 'Fist of Humiliation',
          social_links_attributes: {
            '0': {
              id: 'youtube',
              provider: 'youtube',
              url: 'https://youtube.com/abc',
              sort_priority: '0',
              enabled: '1'
            },
            '1': {
              id: 'facebook',
              provider: 'facebook',
              url: 'https://facebook.com/abc',
              sort_priority: '1',
              enabled: '1'
            }
          },
          footer_menu_links_attributes: {
            '0': {
              id: '0',
              title: 'About',
              url: 'https://example.com/about',
              sort_priority: '0',
              _destroy: ''
            },
            '1': {
              id: '1',
              title: 'Contact us',
              url: 'https://example.com/contact_us',
              sort_priority: '1',
              _destroy: ''
            }
          }
        }}
        lpv = LandingPageVersion.find(landing_page_version.id)
        sections = lpv.parsed_content['sections']
        section = sections.find{|x| x['id'] == section_id}
        expect(section['theme']).to eq 'marketplace_color'
        expect(section['copyright']).to eq 'Fist of Humiliation'
        links = section['links']
        expect(links.size).to eq 2
        first_link = links.first
        expect(first_link['label']).to eq 'About'
        expect(first_link['href']['value']).to eq 'https://example.com/about'
        second_link = links.last
        expect(second_link['label']).to eq 'Contact us'
        expect(second_link['href']['value']).to eq 'https://example.com/contact_us'
        social = section['social']
        expect(social.size).to eq 2
        first_social = social.first
        expect(first_social['service']).to eq 'youtube'
        expect(first_social['url']).to eq 'https://youtube.com/abc'
        second_social = social.last
        expect(second_social['service']).to eq 'facebook'
        expect(second_social['url']).to eq 'https://facebook.com/abc'

        put :update, params: { landing_page_version_id: landing_page_version.id,
                               id: section_id,
                               section: {
          id: 'footer',
          kind: 'footer',
          theme: 'marketplace_color',
          previous_id: 'footer',
          copyright: 'Fist of Humiliation',
          social_links_attributes: {
            '0': {
              id: 'youtube',
              provider: 'youtube',
              url: 'https://youtube.com/abc',
              sort_priority: '0',
              enabled: '1'
            },
            '1': {
              id: 'facebook',
              provider: 'facebook',
              url: 'https://facebook.com/abc',
              sort_priority: '1',
              enabled: '1'
            }
          },
          footer_menu_links_attributes: {
            '0': {
              id: '0',
              title: 'About',
              url: 'https://example.com/about',
              sort_priority: '0',
              _destroy: ''
            }
          }
        }}
        lpv = LandingPageVersion.find(landing_page_version.id)
        sections = lpv.parsed_content['sections']
        section = sections.find{|x| x['id'] == section_id}
        links = section['links']
        expect(links.size).to eq 1
      end

      it 'keeps existing attributes as is' do
        section_id = 'footer'

        footer = landing_page_version.parsed_content['sections'].find{|s| s['id'] == 'footer' }
        footer["social_media_icon_color"] = { "type": "marketplace_data", "id": "primary_color_darken" }
        footer["social_media_icon_color_hover"] = { "type": "marketplace_data", "id": "primary_color" }
        landing_page_version.update_content(landing_page_version.parsed_content)

        put :update, params: { landing_page_version_id: landing_page_version.id,
                               id: section_id,
                               section: {
          id: 'footer',
          kind: 'footer',
          theme: 'marketplace_color',
          previous_id: 'footer',
          copyright: 'Fist of Humiliation',
          social_links_attributes: {
            '0': {
              id: 'youtube',
              provider: 'youtube',
              url: 'https://youtube.com/abc',
              sort_priority: '0',
              enabled: '1'
            },
            '1': {
              id: 'facebook',
              provider: 'facebook',
              url: 'https://facebook.com/abc',
              sort_priority: '1',
              enabled: '1'
            }
          },
          footer_menu_links_attributes: {
            '0': {
              id: '0',
              title: 'About',
              url: 'https://example.com/about',
              sort_priority: '0',
              _destroy: ''
            },
            '1': {
              id: '1',
              title: 'Contact us',
              url: 'https://example.com/contact_us',
              sort_priority: '1',
              _destroy: ''
            }
          }
        }}
        lpv = LandingPageVersion.find(landing_page_version.id)
        sections = lpv.parsed_content['sections']
        section = sections.find{|x| x['id'] == section_id}

        color = {"type" => "marketplace_data", "id" => "primary_color_darken" }
        expect(section["social_media_icon_color"]).to eq color

        hover_color = { "type" => "marketplace_data", "id" => "primary_color" }
        expect(section["social_media_icon_color_hover"]).to eq hover_color
      end
    end
  end
end
