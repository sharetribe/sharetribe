require "spec_helper"

describe "Redirect to HTTPS", type: :request do
  def expect_redirect(http_url, https_url)
    get http_url
    expect(response.status).to eq 301
    expect(response.location).to eq https_url
  end

  shared_context "common with ssl" do
    before do
      APP_CONFIG.always_use_ssl = "true"
    end

    after do
      APP_CONFIG.always_use_ssl = "false"
    end

    it "redirects empty path to HTTPS" do
      expect_redirect("http://#{domain}", "https://#{domain}")
    end

    it "redirects with path to HTTPS" do
      expect_redirect("http://#{domain}/something", "https://#{domain}/something")
    end

    it "redirects with path and parameter to HTTPS" do
      expect_redirect("http://#{domain}/something?more", "https://#{domain}/something?more")
    end

    it "does not happen over HTTPS" do
      get "https://#{domain}"
      expect(response.status).to eq 200
    end

    it "does not redirect HealthCheck" do
      get "http://#{domain}/_health"
      expect(response.status).to eq 200
    end

    it "does not happen when SSL is terminated on proxy" do
      get "http://#{domain}", params: nil, headers: { "X-Forwarded-Proto" => "https" }
      expect(response.status).to eq 200
    end
  end

  shared_context "common no ssl" do
    it "does not happen over HTTP" do
      get "http://#{domain}"
      expect(response.status).to eq 200
    end

    it "does not happen over HTTPS" do
      get "https://#{domain}"

      expect(response.status).to eq 200
    end
  end

  context "for custom domain" do
    let!(:domain) { "market.custom.org" }

    before do
      @community = FactoryGirl.create(:community, :domain => domain, use_domain: true)
      @community.reload
    end

    context "when always_use_ssl is true:" do

      include_context "common with ssl"

      it "redirects and keeps additional labels over HTTP" do
        expect_redirect("http://www.#{domain}", "https://www.#{domain}")
        expect_redirect("http://something.else.#{domain}", "https://something.else.#{domain}")
      end
    end

    context "when always_use_ssl is false" do
      include_context "common no ssl"
    end
  end

  context "for marketplace subdomain" do
    let!(:ident)     { "market" }
    let!(:st_domain) { "example.com" }
    let!(:domain)    { "#{ident}.#{st_domain}" }

    before do
      @community = FactoryGirl.create(:community, :ident => ident, use_domain: false)
      @community.reload
    end

    before(:each) do
      @orig_domain = APP_CONFIG.domain
      APP_CONFIG.domain = st_domain
    end

    after(:each) do
      APP_CONFIG.domain = @orig_domain
    end

    context "when always_use_ssl is true:" do
      include_context "common with ssl"

      it "redirects and strips additional labels over HTTP" do
        expect_redirect("http://www.#{domain}", "https://#{domain}")
        expect_redirect("http://something.else.#{domain}", "https://#{domain}")
      end
    end

    context "when always_use_ssl is false" do
      include_context "common no ssl"
    end
  end
end
