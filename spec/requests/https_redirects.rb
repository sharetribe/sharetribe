require "spec_helper"

describe "Redirect to HTTPS", type: :request do
  before(:each) do
    @domain = "market.custom.org"
    @http_url = "http://#{@domain}"
    @https_url = "https://#{@domain}"
    @community = FactoryGirl.create(:community, :domain => @domain, use_domain: true)

    # Refresh from DB
    @community.reload
  end

  context "when always_use_ssl is true:" do
    before do
      APP_CONFIG.always_use_ssl = "true"
    end

    after do
      APP_CONFIG.always_use_ssl = "false"
    end

    it "when request is over HTTP" do
      get @http_url
      expect(response.status).to eq 301
      expect(response.location).to start_with "https://"
    end

    it "does not happen over HTTPS" do
      get @https_url
      expect(response.status).to eq 200
    end

    it "does not happen when SSL is terminated on proxy" do
      get @http_url, nil, { "X-Forwarded-Proto" => "https" }
      expect(response.status).to eq 200
    end
  end

  context "when always_use_ssl is false" do
    it "does not happen over HTTP" do
      get @http_url
      expect(response.status).to eq 200
    end

    it "does not happen over HTTPS" do
      get @https_url
      expect(response.status).to eq 200
    end
  end
end
