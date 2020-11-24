require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe Admin::LandingPageVersions::SectionsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:landing_page_version) { FactoryGirl.create(:landing_page_version, community: community, version: '1') }
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

  def stubbed_upload(filename, content_type)
    fixture_file_upload("#{Rails.root}/spec/fixtures/#{filename}", content_type, :binary)
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    @request.env[:current_plan] = plan
    user = create_admin_for(community)
    sign_in_for_spec(user)
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

      it 'stores background image and asset_id' do
        section_id = 'hero'
        put :update, params: { landing_page_version_id: landing_page_version.id,
                               id: section_id,
                               bg_image: stubbed_upload('Bison_skull_pile.png', 'image/png'),
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

        default_bg = {"id"=>"default_hero_background", "type"=>"assets"}
        expect(section['background_image']).to eq default_bg

        assets = lpv.parsed_content['assets']
        expect(assets.size).to eq 1
        asset = assets.first
        expect(asset['id']).to eq("default_hero_background")
        expect(asset['asset_id']).to_not be_nil
        expect(asset['src']).to match(/.+\/Bison_skull_pile.png/)
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
        sections = e_lpv.parsed_content['sections'].reject{|s| s['id'] == 'hero'}
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
        sections = e_lpv.parsed_content['sections'].reject{|s| s['id'] == 'hero'}
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
          social_attributes: {
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
          links_attributes: {
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
        expect(social.size).to eq 8
        enabled_social = social.select{|s| s['enabled']}
        expect(enabled_social.size).to eq 2
        first_social = enabled_social.first
        expect(first_social['service']).to eq 'youtube'
        expect(first_social['url']).to eq 'https://youtube.com/abc'
        second_social = enabled_social.last
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
          social_attributes: {
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
          links_attributes: {
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
          social_attributes: {
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
          links_attributes: {
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

  describe 'single_column' do
    it 'creates section with style and color' do
      section_id = 'test1'
      sections = landing_page_version.parsed_content['sections']
      expect(sections.find{|x| x['id'] == section_id}).to eq nil
      post :create, params: { landing_page_version_id: landing_page_version.id,
                              section: {
        kind: 'info',
        variation: 'single_column',
        id: section_id,
        title: 'Shot In the Dark',
        paragraph: 'She only paints with bold colors',
        background_style: 'color',
        background_color_string: '112233',
        cta_enabled: '1',
        button_title: 'Start',
        button_path_string: 'https://site.name/start'
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
      expect(section['background_color']).to eq [0x11, 0x22, 0x33]
      expect(section['background_image']).to be_nil
      expect(section['button_title']).to eq 'Start'

      button_path = {"value" => 'https://site.name/start'}
      expect(section['button_path']).to eq button_path
    end

    it 'creates section without CTA button and with image' do
      section_id = 'test1'
      sections = landing_page_version.parsed_content['sections']
      expect(sections.find{|x| x['id'] == section_id}).to eq nil
      post :create, params: {
        landing_page_version_id: landing_page_version.id,
        section: {
          kind: 'info',
          variation: 'single_column',
          id: section_id,
          title: 'Shot In the Dark',
          paragraph: 'She only paints with bold colors',
          background_style: 'image',
          background_color_string: '112233',
          cta_enabled: '0',
          button_title: 'Start',
          button_path_string: 'https://site.name/start'
        },
        bg_image: stubbed_upload('Bison_skull_pile.png', 'image/png')
      }
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      expect(section['kind']).to eq 'info'
      expect(section['variation']).to eq 'single_column'
      expect(section['id']).to eq section_id
      expect(section['title']).to eq 'Shot In the Dark'
      expect(section['paragraph']).to eq 'She only paints with bold colors'
      expect(section['background_color']).to be_nil
      expect(section['button_title']).to be_nil
      expect(section['button_path']).to be_nil
      expect(section['background_image']).to_not be_nil
      expect_image = {"id"=>"test1_background_image", "type"=>"assets"}
      expect(section['background_image']).to eq expect_image

      asset = lpv.parsed_content['assets'].last
      expect(asset["content_type"]).to eq "image/png"
      expect(asset["id"]).to eq "test1_background_image"
      expect(asset["src"]).to match(/Bison_skull_pile.png$/)
    end
  end

  describe 'listings' do
    let(:listing_1){ FactoryGirl.create(:listing, community: community) }
    let(:listing_2){ FactoryGirl.create(:listing, community: community) }
    let(:listing_3){ FactoryGirl.create(:listing, community: community) }
    let(:listings_section) do
      {"id" => "test1",
       "kind" => "listings",
       "title" => "Shot In the Dark",
       "paragraph" => "She only paints with bold colors",
       "button_color" => {"type"=>"marketplace_data", "id"=>"primary_color"},
       "button_color_hover" =>
      {"type"=>"marketplace_data", "id"=>"primary_color_darken"},
       "button_title" => "Start",
       "button_path" => {"value"=>"https://site.name/start"},
       "price_color" => {"type"=>"marketplace_data", "id"=>"primary_color"},
       "no_listing_image_background_color" =>
        {"type"=>"marketplace_data", "id"=>"primary_color"},
       "no_listing_image_text" => {"type"=>"translation", "id"=>"no_listing_image"},
       "author_name_color_hover" =>
        {"type"=>"marketplace_data", "id"=>"primary_color"},
       "listings" =>
        [{"listing"=>{"type"=>"listing", "id"=>listing_1.id.to_s}},
         {"listing"=>{"type"=>"listing", "id"=>listing_2.id.to_s}},
         {"listing"=>{"type"=>"listing", "id"=>listing_3.id.to_s}}]}
    end

    it 'creates section' do
      section_id = 'test1'
      sections = landing_page_version.parsed_content['sections']
      expect(sections.find{|x| x['id'] == section_id}).to eq nil
      post :create, params: { landing_page_version_id: landing_page_version.id,
                              section: {
        kind: 'listings',
        id: section_id,
        title: 'Shot In the Dark',
        paragraph: 'She only paints with bold colors',
        cta_enabled: '1',
        button_title: 'Start',
        button_path_string: 'https://site.name/start',
        listing_1_id: listing_1.id,
        listing_2_id: listing_2.id,
        listing_3_id: listing_3.id
      }}
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      expect(section['kind']).to eq 'listings'
      expect(section['id']).to eq section_id
      expect(section['title']).to eq 'Shot In the Dark'
      expect(section['paragraph']).to eq 'She only paints with bold colors'
      expect(section['button_title']).to eq 'Start'
      expect(section['button_path']['value']).to eq 'https://site.name/start'
      expect(section['listings'][0]['listing']['id']).to eq listing_1.id.to_s
      expect(section['listings'][1]['listing']['id']).to eq listing_2.id.to_s
      expect(section['listings'][2]['listing']['id']).to eq listing_3.id.to_s
    end

    it 'does not creates section with nonexisting listing ids' do
      section_id = 'test1'
      sections = landing_page_version.parsed_content['sections']
      expect(sections.find{|x| x['id'] == section_id}).to eq nil
      post :create, params: { landing_page_version_id: landing_page_version.id,
                              section: {
        kind: 'listings',
        id: section_id,
        title: 'Shot In the Dark',
        paragraph: 'She only paints with bold colors',
        cta_enabled: '1',
        button_title: 'Start',
        button_path_string: 'https://site.name/start',
        listing_1_id: 99999,
        listing_2_id: 99999,
        listing_3_id: 99999
      }}
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to eq nil
      presenter = assigns(:presenter)
      expect(presenter.section_errors?).to eq true
    end

    it 'updates' do
      section_id = 'test1'
      section = LandingPageVersion::Section::Listings.new(listings_section.merge(landing_page_version: landing_page_version))
      section.save
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      put :update, params: { landing_page_version_id: landing_page_version.id,
                             id: section_id,
                             section: {
        kind: 'listings',
        id: section_id,
        title: 'Blackened Tofu and Black Truffle served with Panamanian Roast Beef',
        paragraph: 'Raw Salmon Blobs atop Paleo-friendly Garlic Pie',
        cta_enabled: '1',
        button_title: 'Start',
        button_path_string: 'https://site.name/start',
        listing_1_id: listing_1.id,
        listing_2_id: listing_2.id,
        listing_3_id: listing_3.id
      }}
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      expect(section['title']).to eq 'Blackened Tofu and Black Truffle served with Panamanian Roast Beef'
      expect(section['paragraph']).to eq 'Raw Salmon Blobs atop Paleo-friendly Garlic Pie'
    end
  end

  describe 'categories' do
    let(:category_1) { FactoryGirl.create(:category, community: community) }
    let(:category_2) { FactoryGirl.create(:category, community: community) }
    let(:category_3) { FactoryGirl.create(:category, community: community) }

    it 'creates categories section with title and paragraph' do
      section_id = 'all_categories'
      post :create, params: {
      landing_page_version_id: landing_page_version.id,
      section: {
          kind: 'categories',
          id: section_id,
          title: 'Explore Destinations',
          paragraph: 'We have something for everyone!',
          categories_attributes: {
            '0': {
              id: '0',
              sort_priority: '0',
              category_id: category_3.id.to_s,
              image: stubbed_upload('Bison_skull_pile.png', 'image/png')
            },
            '1': {
              id: '1',
              sort_priority: '1',
              category_id: category_1.id.to_s,
              image: stubbed_upload('Bison_skull_pile.png', 'image/png')
            },
            '2': {
              id: '2',
              sort_priority: '2',
              category_id: category_2.id.to_s,
              image: stubbed_upload('Bison_skull_pile.png', 'image/png')
            }
          }
        },
      bg_image: stubbed_upload('ds1-2.jpg', 'image/jpeg')
      }
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      assets = lpv.parsed_content['assets']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      expect(section['title']).to eq "Explore Destinations"
      expect(section['paragraph']).to eq "We have something for everyone!"
      categories = section['categories']
      expect(categories.size).to eq 3
      expect(categories[0]['category']['id']).to eq category_3.id
      expect(categories[1]['category']['id']).to eq category_1.id
      expect(categories[2]['category']['id']).to eq category_2.id

      categories.each do |category|
        asset_image_id = category['background_image']['id']
        expect(asset_image_id).to_not eq nil
        asset = assets.find{|x| x['id'] == asset_image_id }
        expect(asset).to_not eq nil
      end

      bg_image_id = section['background_image']['id']
      asset = assets.find{|x| x['id'] == bg_image_id }
      expect(asset).to_not eq nil
    end
  end

  describe 'locations' do

    it 'creates locations section with title and paragraph' do
      section_id = 'best_locations'
      loc_helsinki = 'https://store.com/?boundingbox=59.922489%2C24.782876%2C60.297839%2C25.254485&distance_max=24.6215420997966&lc=60.169856%2C24.938379&lq=Helsinki%2C+Finland'
      loc_tampere = 'https://store.com/?boundingbox=61.427282%2C23.542201%2C61.836574%2C24.118384&distance_max=27.376458985155967&lc=61.497752%2C23.760954&lq=Tampere%2C+Finland'
      loc_rovaniemi = 'https://store.com/?boundingbox=66.155374%2C24.736871%2C67.184525%2C27.326679&distance_max=80.76841350229911&lc=66.503948%2C25.729391&lq=Rovaniemi%2C+Finland'
      loc_nowhere = 'https://store.com/?distance_max=80&lc=0%2C0'

      post :create, params: {
        landing_page_version_id: landing_page_version.id,
        section: {
          kind: 'locations',
          id: section_id,
          title: 'Explore Destinations',
          paragraph: 'We have something for everyone!',
          locations_attributes: {
            '0': {
              id: '0',
              sort_priority: '0',
              title: 'Helsinki',
              asset_id: '',
              url: loc_helsinki,
              image: stubbed_upload('Australian_painted_lady_big.jpg', 'image/jpeg')
            },
            '1': {
              id: '1',
              sort_priority: '1',
              title: 'Tampere',
              asset_id: '',
              url: loc_tampere,
              image: stubbed_upload('Australian_painted_lady.jpg', 'image/jpeg')
            },
            '2': {
              id: '2',
              sort_priority: '2',
              title: 'Rovaniemi',
              asset_id: '',
              url: loc_rovaniemi,
              image: stubbed_upload('Bison_skull_pile.png', 'image/png')
            },
            '3': {
              id: '3',
              sort_priority: '3',
              title: 'Nowhere',
              asset_id: '',
              url: loc_nowhere,
              image: stubbed_upload('ds1-1.jpg', 'image/jpeg')
            }
          }
        },
        bg_image: stubbed_upload('ds1-2.jpg', 'image/jpeg')
      }
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      assets = lpv.parsed_content['assets']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      expect(section['title']).to eq "Explore Destinations"
      expect(section['paragraph']).to eq "We have something for everyone!"

      locations = section['locations']
      expect(locations.size).to eq 4

      expect(locations[0]['title']).to eq "Helsinki"
      expect(locations[1]['title']).to eq "Tampere"
      expect(locations[2]['title']).to eq "Rovaniemi"
      expect(locations[3]['title']).to eq "Nowhere"

      expect(locations[0]['location']['value']).to eq loc_helsinki
      expect(locations[1]['location']['value']).to eq loc_tampere
      expect(locations[2]['location']['value']).to eq loc_rovaniemi
      expect(locations[3]['location']['value']).to eq loc_nowhere

      asset_ids = []
      locations.each do |location|
        asset_image_id = location['background_image']['id']
        expect(asset_image_id).to_not eq nil
        asset = assets.find{|x| x['id'] == asset_image_id }
        expect(asset).to_not eq nil
        asset_ids << asset_image_id
      end

      bg_image_id = section['background_image']['id']
      asset = assets.find{|x| x['id'] == bg_image_id }
      expect(asset).to_not eq nil

      asset_ids << bg_image_id
      expect(asset_ids.uniq.size).to eq 5
    end
  end

  describe 'locations' do

    it 'creates locations section with title and paragraph' do
      section_id = 'best_locations'
      loc_helsinki = 'https://store.com/?boundingbox=59.922489%2C24.782876%2C60.297839%2C25.254485&distance_max=24.6215420997966&lc=60.169856%2C24.938379&lq=Helsinki%2C+Finland'
      loc_tampere = 'https://store.com/?boundingbox=61.427282%2C23.542201%2C61.836574%2C24.118384&distance_max=27.376458985155967&lc=61.497752%2C23.760954&lq=Tampere%2C+Finland'
      loc_rovaniemi = 'https://store.com/?boundingbox=66.155374%2C24.736871%2C67.184525%2C27.326679&distance_max=80.76841350229911&lc=66.503948%2C25.729391&lq=Rovaniemi%2C+Finland'

      post :create, params: {
        landing_page_version_id: landing_page_version.id,
        section: {
          kind: 'locations',
          id: section_id,
          title: 'Explore Destinations',
          paragraph: 'We have something for everyone!',
          locations_attributes: {
            '0': {
              id: '0',
              sort_priority: '0',
              title: 'Helsinki',
              url: loc_helsinki,
              image: stubbed_upload('Bison_skull_pile.png', 'image/png')
            },
            '1': {
              id: '1',
              sort_priority: '1',
              title: 'Tampere',
              url: loc_tampere,
              image: stubbed_upload('Bison_skull_pile.png', 'image/png')
            },
            '2': {
              id: '2',
              sort_priority: '2',
              title: 'Rovaniemi',
              url: loc_rovaniemi,
              image: stubbed_upload('Bison_skull_pile.png', 'image/png')
            }
          }
        }
      }
      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      assets = lpv.parsed_content['assets']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      expect(section['title']).to eq "Explore Destinations"
      expect(section['paragraph']).to eq "We have something for everyone!"

      locations = section['locations']
      expect(locations.size).to eq 3

      expect(locations[0]['title']).to eq "Helsinki"
      expect(locations[1]['title']).to eq "Tampere"
      expect(locations[2]['title']).to eq "Rovaniemi"

      expect(locations[0]['location']['value']).to eq loc_helsinki
      expect(locations[1]['location']['value']).to eq loc_tampere
      expect(locations[2]['location']['value']).to eq loc_rovaniemi

      locations.each do |location|
        asset_image_id = location['background_image']['id']
        expect(asset_image_id).to_not eq nil
        asset = assets.find{|x| x['id'] == asset_image_id }
        expect(asset).to_not eq nil
      end
    end
  end

  describe 'video' do
    it "creates video section" do
      video_id = 'UffchBUUIoI'
      section_id = 'video_section'
      post :create, params: {
        landing_page_version_id: landing_page_version.id,
        section: {
          kind: 'video',
          id: section_id,
          youtube_video_id: video_id,
          text: "Play Video",
          autoplay: "no"
        }
      }

      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == section_id}
      expect(section).to_not eq nil
      expect(section['text']).to eq "Play Video"
      expect(section['autoplay']).to eq false
      expect(section['youtube_video_id']).to eq video_id
    end

    it "normalizes section id" do
      video_id = 'UffchBUUIoI'
      section_id = ' Video Section_Sample 1!!!! - Here        &'
      post :create, params: {
        landing_page_version_id: landing_page_version.id,
        section: {
          kind: 'video',
          id: section_id,
          youtube_video_id: video_id,
          text: "Play Video",
          autoplay: "false"
        }
      }

      lpv = LandingPageVersion.find(landing_page_version.id)
      sections = lpv.parsed_content['sections']
      section = sections.find{|x| x['id'] == 'Video-Section_Sample-1-Here'}
      expect(section).to_not eq nil
      expect(section['autoplay']).to eq false
    end
  end
end
# rubocop:enable Metrics/BlockLength
