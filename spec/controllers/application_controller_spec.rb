require 'spec_helper'

describe ApplicationController, type: :controller do
  controller do
    # a mock method to be able to call index without route
    def index
      # do nothing as we are testing the filters here only
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
          expect(response).to render_template("public/501.html")
        end

        it "redirects to aalto community if longer request path (to keep legacy email links working)" do
          request.host = "login.lvh.me"
          request.env['HTTP_REFERER'] = request.env['HTTP_ORIGIN'] = ''
          request.env['REQUEST_PATH'] = '/en/people/s0m3Gu1dr4nd0mn3ss/messages/received/42'
          get :index
          expect(response).to redirect_to("http://aalto.kassi.eu/en/people/s0m3Gu1dr4nd0mn3ss/messages/received/42")
        end

      end

      describe "HTTP_REFERER is known but action is wrong for login domain" do

        it "redirects back to the referer domain and shows error" do
          request.host = "login.lvh.me"
          request.env['HTTP_REFERER'] = 'http://test.lvh.me:9887'
          request.env['HTTP_ORIGIN'] = ''
          get :index
          expect(response).to redirect_to("http://test.lvh.me:9887/en")
          expect(flash[:error].class).to eq(Array)
          expect(flash[:error][0]).to eq("error_with_session")
        end
      end
    end
  end

  describe "#check_auth_token" do
    it "logs person in when auth_token is valid" do
      p1 = FactoryGirl.create(:person)
      t = AuthToken.create!(:person_id => p1.id, :expires_at => 10.minutes.from_now, :token_type => "login")
      get :index, params: { :auth => t.token}
      expect(response.status).to eq(302) #redirection to url withouth token in query string
      expect(assigns("current_user").id).to eq(p1.id)
    end
  end
end

describe ApplicationController, type: :controller do
  render_views
  controller do
    def index
      # should be intercepted in filter
    end
  end

  describe "showing not available message" do
    it "redirects to /not_available for deleted community" do
      community = FactoryGirl.create(:community)
      community.update(deleted: true)

      # stub request.env like MarketplaceLookup middleware
      request.host = "#{community.ident}.lvh.me:9887"
      redirect_reason = ::MarketplaceRouter.redirect_reason(
        community: {
          use_domain: false,
          deleted: true,
          closed: false,
          hold: false,
          expired: false,
          ident: community.ident
        },
        host: request.host,
        no_communities: false,
        app_domain: 'lvh.me')
      request.env[:redirect_reason] = redirect_reason
      request.env[:current_marketplace] = community

      get :index
      expect(response).to redirect_to("http://#{community.ident}.lvh.me:9887/not_available?locale=en")
    end

    it "redirects to /not_available for closed community" do
      community = FactoryGirl.create(:community)
      community.update(deleted: true)

      # stub request.env like MarketplaceLookup middleware
      request.host = "#{community.ident}.lvh.me:9887"
      redirect_reason = ::MarketplaceRouter.redirect_reason(
        community: {
          use_domain: false,
          deleted: false,
          closed: true,
          hold: false,
          expired: false,
          ident: community.ident
        },
        host: request.host,
        no_communities: false,
        app_domain: 'lvh.me')
      request.env[:redirect_reason] = redirect_reason
      request.env[:current_marketplace] = community
      request.env[:current_plan] = {status: :active, expired: false, closed: true}

      get :index
      expect(response).to redirect_to("http://#{community.ident}.lvh.me:9887/not_available?locale=en")
    end

    it "redirects to /not_available for community on hold" do
      community = FactoryGirl.create(:community)
      community.update(deleted: true)

      # stub request.env like MarketplaceLookup middleware
      request.host = "#{community.ident}.lvh.me:9887"
      redirect_reason = ::MarketplaceRouter.redirect_reason(
        community: {
          use_domain: false,
          deleted: false,
          closed: false,
          hold: true,
          expired: false,
          ident: community.ident
        },
        host: request.host,
        no_communities: false,
        app_domain: 'lvh.me')
      request.env[:redirect_reason] = redirect_reason
      request.env[:current_marketplace] = community
      request.env[:current_plan] = {status: :hold, expired: false, closed: false}

      get :index
      expect(response).to redirect_to("http://#{community.ident}.lvh.me:9887/not_available?locale=en")
    end

  end
end

describe ApplicationController, type: :controller do
  render_views

  describe "showing not available message" do
    it "renders message on request /not_available for deleted community" do
      community = FactoryGirl.create(:community)
      community.update(deleted: true)

      # stub request.env like MarketplaceLookup middleware
      request.host = "#{community.ident}.lvh.me:9887"
      redirect_reason = ::MarketplaceRouter.redirect_reason(
        community: {
          use_domain: false,
          deleted: true,
          closed: false,
          hold: false,
          expired: false,
          ident: community.ident
        },
        host: request.host,
        no_communities: false,
        app_domain: 'lvh.me')
      request.env[:redirect_reason] = redirect_reason
      request.env[:current_marketplace] = community

      get :not_available
      expect(response.body).to match(/team has decided to close this platform/)
    end

    it "renders message on request to /not_available for closed community" do
      community = FactoryGirl.create(:community)
      community.update(deleted: true)

      # stub request.env like MarketplaceLookup middleware
      request.host = "#{community.ident}.lvh.me:9887"
      redirect_reason = ::MarketplaceRouter.redirect_reason(
        community: {
          use_domain: false,
          deleted: false,
          closed: true,
          hold: false,
          expired: false,
          ident: community.ident
        },
        host: request.host,
        no_communities: false,
        app_domain: 'lvh.me')
      request.env[:redirect_reason] = redirect_reason
      request.env[:current_marketplace] = community
      request.env[:current_plan] = {status: :active, expired: false, closed: true}

      get :not_available
      expect(response.body).to match(/team has decided to close this platform/)
    end

    it "renders message on request to /not_available for community on hold" do
      community = FactoryGirl.create(:community)
      community.update(deleted: true)

      # stub request.env like MarketplaceLookup middleware
      request.host = "#{community.ident}.lvh.me:9887"
      redirect_reason = ::MarketplaceRouter.redirect_reason(
        community: {
          use_domain: false,
          deleted: false,
          closed: false,
          hold: true,
          expired: false,
          ident: community.ident
        },
        host: request.host,
        no_communities: false,
        app_domain: 'lvh.me')
      request.env[:redirect_reason] = redirect_reason
      request.env[:current_marketplace] = community
      request.env[:current_plan] = {status: :hold, expired: false, closed: false}

      get :not_available
      expect(response.body).to match(/team has decided to pause things/)
    end

  end
end

describe ApplicationController, type: :controller do
  render_views
  controller do
    def index
      head :ok
    end
  end

  describe '#disarm_custom_head_script' do
    it "disables custom head script if disarm param present" do
      get :index, params: {}
      expect(assigns("disable_custom_head_script")).to eq(nil)
      get :index, params: {:disarm => "true"}
      expect(assigns("disable_custom_head_script")).to eq(true)
    end
  end
end

describe ApplicationController, type: :controller do
  render_views
  controller do
    def index
      head :ok
    end
  end

  describe 'seo service for meta tags' do
    it "initializes seo_service" do
      community = FactoryGirl.create(:community)
      request.env[:current_marketplace] = community
      get :index, params: {}
      expect(assigns("seo_service")).to be_kind_of(SeoService)
    end
  end
end
