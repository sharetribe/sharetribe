require "spec_helper"

describe "HSTS header", type: :request do
  before do
    @hsts_max_age = 10
  end

  shared_context "common with ssl" do
    before do
      APP_CONFIG.always_use_ssl = true
    end

    after do
      APP_CONFIG.always_use_ssl = false
    end

    it "header is set" do
      get "https://#{domain}"

      expect(response.status).to eq(200)
      expect(response.headers['Strict-Transport-Security']).to eq("max-age=#{@hsts_max_age}")
    end
  end

  shared_context "common without ssl" do
    it "header not set" do
      get "https://#{domain}"

      expect(response.status).to eq(200)
      expect(response.headers['Strict-Transport-Security']).to eq(nil)
    end
  end

  context "for custom domain" do
    let!(:domain) { "market.custom.org" }

    before do
      @community = FactoryGirl.create(:community, :domain => domain, use_domain: true)
      @community.reload
    end

    context "when always_use_ssl is true:" do
      before do
        @community.hsts_max_age = @hsts_max_age
        @community.save
      end

      after do
        @community.hsts_max_age = nil
        @community.save
      end
      include_context "common with ssl"
    end

    context "when always_use_ssl is false" do
      include_context "common without ssl"
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
      APP_CONFIG.hsts_max_age = 10
    end

    after(:each) do
      APP_CONFIG.domain = @orig_domain
      APP_CONFIG.hsts_max_age = 0
    end

    context "when always_use_ssl is true:" do
      include_context "common with ssl"
    end

    context "when always_use_ssl is false" do
      include_context "common without ssl"
    end
  end
end
