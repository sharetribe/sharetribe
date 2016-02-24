require "spec_helper"

describe "HTTP basic auth", type: :request do
  before do
    APP_CONFIG.use_http_auth = true
    APP_CONFIG.http_auth_username = "testuser"
    APP_CONFIG.http_auth_password = "secret"
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
    get "/int_api/check_email_availability", email: "test123@example.com"
    expect(response.status).to eq(200)
  end

  it "is not required when disabled" do
    APP_CONFIG.use_http_auth = false
    get "/"
    expect(response.status).not_to eq(401)
  end
end
