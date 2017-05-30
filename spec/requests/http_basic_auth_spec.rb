require "spec_helper"

describe "HTTP basic auth", type: :request do
  before do
    APP_CONFIG.use_http_auth = true
    APP_CONFIG.http_auth_username = "testuser"
    APP_CONFIG.http_auth_password = "secret"
  end

  before(:each) do
    @domain = "market.custom.org"
    @http_url = "http://#{@domain}"
    @https_url = "https://#{@domain}"
    @community = FactoryGirl.create(:community, :domain => @domain, use_domain: true)

    # Refresh from DB
    @community.reload
  end

  after do
    APP_CONFIG.use_http_auth = false
  end

  it "is required when enabled" do
    get "/"
    expect(response.status).to eq(401)

    get "/admin"
    expect(response.status).to eq(401)
  end

  it "is bypassed for internal API" do
    post "/int_api/prospect_emails", params: {email: "test123@example.com"}
    expect(response.status).to eq(200)
  end

  it "is not required when disabled" do
    APP_CONFIG.use_http_auth = false
    get "/"
    expect(response.status).not_to eq(401)
  end

  context "when always_use_ssl is true" do
    before do
      APP_CONFIG.always_use_ssl = true
    end

    after do
      APP_CONFIG.always_use_ssl = false
    end

    it "is required after redirect" do
      get @http_url
      expect(response.status).to eq(301)

      get response.location
      expect(response.status).to eq(401)
    end

    it "is required when using HTTPS" do
      get @https_url
      expect(response.status).to eq(401)
    end
  end
end
