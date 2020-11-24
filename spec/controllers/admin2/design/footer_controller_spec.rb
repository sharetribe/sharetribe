require 'spec_helper'

describe Admin2::Design::FooterController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:plan) do
    {
      expired: false,
      features: {
        whitelabel: true,
        admin_email: true,
        footer: true
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

  describe "#update_footer" do
    it 'works' do
      params = {"community" =>
        {"footer_theme" => "light",
         "footer_enabled" => 1,
         "footer_menu_links_attributes" =>
           {"0" =>
            {"id" => "",
             "entity_type" => "for_footer",
             "sort_priority" => "0",
             "_destroy" => "false",
             "translations_attributes" =>
              {"0"=>{"locale" => 'en', "title"=>"ccc", "url"=>"http://example.com"}}}},
         "footer_copyright" => "Sample",
         "social_links_attributes" =>
          {"0" =>
            {"id" => "",
             "sort_priority" => "0",
             "provider" => "youtube",
             "url" => "hoho"},
           "1" =>
            {"id" => "",
             "sort_priority" => "1",
             "provider" => "facebook",
             "url" => ""},
           "2" =>
            {"id" => "",
             "sort_priority" => "2",
             "provider" => "twitter",
             "enabled" => "0",
             "url" => ""},
           "3" =>
            {"id" => "",
             "sort_priority" => "3",
             "provider" => "instagram",
             "url" => ""},
           "4" =>
            {"id" => "",
             "sort_priority" => "4",
             "provider" => "googleplus",
             "url" => ""},
           "5" =>
            {"id" => "",
             "sort_priority" => "5",
             "provider" => "linkedin",
             "url" => ""},
           "6" =>
            {"id" => "",
             "sort_priority" => "6",
             "provider" => "pinterest",
             "url" => ""},
           "7" =>
            {"id" => "",
             "sort_priority" => "7",
             "provider" => "soundcloud",
             "url" => ""}
          }
        }

      }

      expect(community.footer_menu_links.count).to eq 0
      expect(community.social_links.count).to eq 0
      expect(community.footer_enabled).to eq false
      patch :update_footer, params: params
      expect(community.footer_enabled).to eq true
      expect(community.reload.footer_menu_links.count).to eq 1
      expect(community.social_links.count).to eq 8
      expect(community.social_links.enabled.count).to eq 1
      expect(community.social_links.first.provider).to eq 'youtube'
    end
  end
end

