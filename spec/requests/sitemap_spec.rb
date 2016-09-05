require 'spec_helper'

RSpec.describe SitemapController, type: :request do

  let(:valid_session) { {} }

  before(:each) do
    @domain = "marketplace.example.com"
    @community = FactoryGirl.create(:community, domain: @domain, use_domain: true)

    @listing = FactoryGirl.create(:listing, community_id: @community.id)
    @community2 = FactoryGirl.create(:community)
    @listing2 = FactoryGirl.create(:listing, community_id: @community2.id)
  end

  describe "GET #sitemap" do
    it "creates sitemap" do
      get "http://#{@domain}/sitemap.xml.gz"
      expect(response.status).to eq(200)
    end

    it "contains root url" do
      get "http://#{@domain}/sitemap.xml.gz"
      expect(ActiveSupport::Gzip.decompress(response.body))
        .to match("<loc>http[^<]*"+@community.domain+"[^<]*</loc>")
    end

    it "contains listing" do
      get "http://#{@domain}/sitemap.xml.gz"
      expect(ActiveSupport::Gzip.decompress(response.body))
        .to match(Regexp.new("listings/"+@listing.id.to_s))
    end

    it "contains listing's nice name" do
      get "http://#{@domain}/sitemap.xml.gz"
      expect(ActiveSupport::Gzip.decompress(response.body))
        .to match(Regexp.new("listings/"+@listing.to_param))
    end

    it "doesn't contain other community listing" do
      get "http://#{@domain}/sitemap.xml.gz"
      expect(ActiveSupport::Gzip.decompress(response.body))
        .to_not match(Regexp.new("listings/"+@listing2.id.to_s))
    end

    it "if community is private returns forbidden" do
      @community.update(private: true)
      get "http://#{@domain}/sitemap.xml.gz"
      expect(response.status).to eq(403)
    end

    it "if community is deleted returns not found" do
      @community.update(deleted: true)
      get "http://#{@domain}/sitemap.xml.gz"
      expect(response.status).to eq(404)
    end

    it "if community is deleted and private returns not found" do
      @community.update(deleted: true, private: true)
      get "http://#{@domain}/sitemap.xml.gz"
      expect(response.status).to eq(404)
    end
  end

end
