require 'spec_helper'

describe Admin::AdminBaseController, type: :controller do
  controller do
    def index
      head :ok
    end
  end

  describe "redirect non admin" do
    let(:community) { FactoryGirl.create(:community) }
    let(:person) {  FactoryGirl.create(:person, member_of: community) }
    let(:admin) { FactoryGirl.create(:person, member_of: community, member_is_admin: true) }

    before(:each) do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
    end

    it "redirect visitor to login" do
      get :index
      expect(response).to have_http_status(302)
      expect(response).to redirect_to('/en/login')
    end

    it "redirect non admin to homepage" do
      sign_in_for_spec(person)
      get :index
      expect(response).to have_http_status(302)
      expect(response).to redirect_to('/')
    end

    it "does not redirect admin" do
      sign_in_for_spec(admin)
      get :index
      expect(response).to have_http_status(200)
    end
  end
end
