require 'spec_helper'

describe Admin::Communities::FooterController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:plan) do
    {
      expired: false,
      features: {
        whitelabel: true,
        admin_email: true
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

  describe "#update" do
    it 'works' do
      params = {"community"=>
        {"footer_theme"=>"light",
         "footer_menu_links_attributes"=>
          {"0"=>
            {"id"=>"",
             "entity_type"=>"for_footer",
             "sort_priority"=>"0",
             "_destroy"=>"false",
             "translation_attributes"=>
              {"en"=>{"title"=>"ccc", "url"=>"http://example.com"}}}},
         "footer_copyright"=>"Sample"}}

      expect(community.footer_menu_links.count).to eq 0
      put :update, params: params
      expect(community.reload.footer_menu_links.count).to eq 1
    end
  end
end

