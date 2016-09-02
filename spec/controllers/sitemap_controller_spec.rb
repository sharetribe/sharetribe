require 'spec_helper'

RSpec.describe SitemapController, type: :controller do

  let(:valid_session) { {} }

  before(:each) do
    @community = FactoryGirl.create(:community)
    @current_community = @community
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @person = FactoryGirl.create(:person)

    FactoryGirl.create(:community_membership, :person => @person, :community => @community)
    @listing = FactoryGirl.create(:listing, community_id: @community.id)
    @community2 = FactoryGirl.create(:community)
    @listing2 = FactoryGirl.create(:listing, community_id: @community2.id)
  end

  describe "GET #sitemap" do
    it "creates sitemap" do
      get :sitemap, {}, valid_session
      expect(response.status).to eq(200)
    end

    it "contains root url" do
      get :sitemap, {}, valid_session
      gzipped = response.body
      ungzipped = ActiveSupport::Gzip.decompress(gzipped)
      expect(ungzipped).to match("<loc>http[^<]*"+@community.ident+"[^<]*</loc>")
    end

    it "contains listing" do
      get :sitemap, {}, valid_session
      gzipped = response.body
      ungzipped = ActiveSupport::Gzip.decompress(gzipped)
      expect(ungzipped).to match(Regexp.new("listings/"+@listing.id.to_s))
    end

    it "contains listing's nice name" do
      get :sitemap, {}, valid_session
      gzipped = response.body
      ungzipped = ActiveSupport::Gzip.decompress(gzipped)
      expect(ungzipped).to match(Regexp.new("listings/"+@listing.to_param))
    end

    it "doesn't contain other community listing" do
      get :sitemap, {}, valid_session
      gzipped = response.body
      ungzipped = ActiveSupport::Gzip.decompress(gzipped)
      expect(ungzipped).to_not match(Regexp.new("listings/"+@listing2.id.to_s))
    end

    it "if community is private returns forbidden" do
      @community.update(private: true)
      get :sitemap, {}, valid_session
      expect(response.status).to eq(403)
    end

    it "if community is deleted returns not found" do
      @community.update(deleted: true)
      get :sitemap, {}, valid_session
      expect(response.status).to eq(404)
    end

    it "if community is deleted and private returns not found" do
      @community.update(deleted: true, private: true)
      get :sitemap, {}, valid_session
      expect(response.status).to eq(404)
    end
  end

end
