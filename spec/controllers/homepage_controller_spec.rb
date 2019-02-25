require 'spec_helper'

describe HomepageController, type: :controller do
  render_views

  let(:plan) do
    {
      expired: false,
      features: {
        whitelabel: true,
        admin_email: true,
        footer: false
      },
      created_at: Time.zone.now,
      updated_at: Time.zone.now
    }
  end

  describe "title and description" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.ident}.lvh.me"
      @request.env[:current_marketplace] = @community
      @request.env[:current_plan] = plan
      @user = create_admin_for(@community)
      @user.update(is_admin: true)
      sign_in_for_spec(@user)
    end

    describe "#index" do
      it "renders default title and description" do
        get :index
        expect(response.body).to match('<title>Sharetribe - Test slogan</title>')
        expect(response.body).to match("<meta content='Test description - Test slogan' name='description'>")
      end

      it "renders updated meta title and description" do
        @community.community_customizations.first.update(meta_title: "SEO Title", meta_description: "SEO Description")
        get :index
        expect(response.body).to match('<title>SEO Title</title>')
        expect(response.body).to match("<meta content='SEO Description' name='description'>")
      end
    end
  end
end
