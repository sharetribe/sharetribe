require 'spec_helper'

describe ApplicationController do
  controller do
    # a mock method to be able to call index without route
    def index
      # do nothing as we are testing the filters here only
    end
  end

  describe "handling RestClient::Unauthorized exceptions" do

    controller do
      # a mock method to raise the error
      def index
        raise RestClient::Unauthorized
      end
    end

    it "logs the user out from Sharetribe" do
      get :index
      session[:person_id].should be_nil
      assigns("current_user").should be_nil
    end

    if APP_CONFIG.login_domain
      it "shows flash error" do
        @request.host = "login.lvh.me"
        request.env['HTTP_REFERER'] = 'http://test.lvh.me:9887'
        get :index
        flash[:error].class.should == Array
        flash[:error][0].should eq("error_with_session")
      end
    end
  end

  describe "handling wrong requests coming to login domain" do
    if APP_CONFIG.login_domain
      controller do
        # a mock method to be able to call index without route
        def index
          # do nothing as we are testing the filters here only
        end
      end

      describe "HTTP_REFERER is blank" do

        it "shows error an page" do
          request.host = "login.lvh.me"
          request.env['HTTP_REFERER'] = request.env['HTTP_ORIGIN'] = ''
          get :index
          response.should render_template("public/501.html")
        end

        it "redirects to aalto community if longer request path (to keep legacy email links working)" do
          request.host = "login.lvh.me"
          request.env['HTTP_REFERER'] = request.env['HTTP_ORIGIN'] = ''
          request.env['REQUEST_PATH'] = '/en/people/s0m3Gu1dr4nd0mn3ss/messages/received/42'
          get :index
          response.should redirect_to("http://aalto.kassi.eu/en/people/s0m3Gu1dr4nd0mn3ss/messages/received/42")
        end

      end

      describe "HTTP_REFERER is known but action is wrong for login domain" do

        it "redirects back to the referer domain and shows error" do
          request.host = "login.lvh.me"
          request.env['HTTP_REFERER'] = 'http://test.lvh.me:9887'
          request.env['HTTP_ORIGIN'] = ''
          get :index
          response.should redirect_to("http://test.lvh.me:9887/en")
          flash[:error].class.should == Array
          flash[:error][0].should eq("error_with_session")
        end
      end
    end
  end

  describe "#check_auth_token" do
    it "logs person in when auth_token is valid" do
      p1 = FactoryGirl.create(:person)
      t = AuthToken.create!(:person_id => p1.id, :expires_at => 10.minutes.from_now, :token_type => "login")
      get :index, {:auth => t.token}
      response.status.should == 302 #redirection to url withouth token in query string
      assigns("current_user").id.should == p1.id
    end

  end

  describe "#fetch_community" do

    controller do
      def index
        # do nothing as we are testing the filters here only
        # just return a dummy json
        render :json => "test_result".to_json
      end
    end

    it "gets the right community by subdomain" do
      c1 = FactoryGirl.create(:community, :ident => "test23")
      c2 = FactoryGirl.create(:community, :domain => "test23.custom.org")
      request.host = "test23.lvh.me"
      get :index
      assigns["current_community"].id.should == c1.id
    end

    it "gets the right community by full domain even when matching subdomain exists" do
      c1 = FactoryGirl.create(:community, :domain => "market.custom.org")
      c2 = FactoryGirl.create(:community, :ident => "market")
      request.host = "market.custom.org"
      get :index
      assigns["current_community"].id.should == c1.id
    end

  end

  describe "ApplicationController.fetch_temp_flags" do
    let(:session) { {feature_flags: [:shipping].to_set} }
    let(:params) { {enable_feature: "booking"} }

    it "fetches temporary flags from session and params" do
      expect(ApplicationController.fetch_temp_flags(true, params, session)).to eq [:shipping, :booking].to_set
    end

    it "returns empty set if not admin" do
      expect(ApplicationController.fetch_temp_flags(false, params, session)).to eq [].to_set
    end
  end

  describe "should force ssl for path" do

    def expect_redirect(path, should_not_redirect)
      expect(ApplicationController.should_not_redirect_path_to_https(path))
        .to eq(should_not_redirect)
    end

    def should_redirect(path)
      expect_redirect(path, false)
    end

    def should_not_redirect(path)
      expect_redirect(path, true)
    end

    it "returns true if should redirect" do
      should_not_redirect("/robots.txt")
      should_not_redirect("/ABCDEF1234567890.txt")
      should_redirect("/.txt")
      should_redirect("/txt")
      should_redirect("/ABCDEF1234567890")
      should_redirect("/subfolder/ABCDEF1234567890.txt")
      should_redirect("/ABCDEF1234567890.txt_backup")
    end
  end

  describe "#parse_community_identifiers_from_request" do
    it "parses ident from host" do
      expect(ApplicationController.parse_community_identifiers_from_host("market.sharetribe.com", "sharetribe.com")).to eq({ident: "market"})
    end

    it "parses ident (with www) from host" do
      expect(ApplicationController.parse_community_identifiers_from_host("www.market.sharetribe.com", "sharetribe.com")).to eq({ident: "market"})
    end

    it "parses domain from host" do
      expect(ApplicationController.parse_community_identifiers_from_host("www.market.com", "sharetribe.com")).to eq({domain: "www.market.com"})
    end
  end
end
