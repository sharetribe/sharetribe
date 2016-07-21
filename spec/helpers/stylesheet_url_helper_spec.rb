require "spec_helper"

def stub_stylesheet(community, url)
  allow(community).to receive(:has_custom_stylesheet?) { true }
  allow(community).to receive(:custom_stylesheet_url) { url }
end

def expect_stylesheet_url(community, url)
  expect { |b| with_stylesheet_url(community, &b) }.to yield_with_args(url)
end

RSpec.describe ApplicationHelper, type: :helper do

  describe "stylesheet url" do

    before(:each) do
      @community = double()
      allow(@community).to receive(:has_custom_stylesheet?) { false }
    end

    context "without user_asset_host" do
      before(:each) do
        @orig_assets_host = APP_CONFIG.user_asset_host
        APP_CONFIG.user_asset_host = nil
      end

      after(:each) do
        APP_CONFIG.user_asset_host = @orig_assets_host
      end

      it "is application.css without custom stylesheet" do
        expect_stylesheet_url(@community, "application")
      end

      it "is correct for custom stylesheet" do
        stub_stylesheet(@community, "foostyle")
        expect_stylesheet_url(@community, "/assets/foostyle")
      end

      it "is correct for custom absolute urls" do
        stub_stylesheet(@community, "http://example.com/foostyle.css")
        expect_stylesheet_url(@community, "http://example.com/foostyle.css")
      end
    end

    context "with user_asset_host" do
      before(:each) do
        @cdn = "http://cdn.example.com"
        APP_CONFIG.user_asset_host = @cdn
      end

      after(:each) do
        APP_CONFIG.user_asset_host = nil
      end

      it "is application.css without custom stylesheet" do
        expect_stylesheet_url(@community, "application")
      end

      it "is correct with custom stylesheet" do
        stub_stylesheet(@community, "foostyle")
        expect_stylesheet_url(@community, "#{@cdn}/assets/foostyle")
      end

      it "is correct with custom absolute urls" do
        stub_stylesheet(@community, "http://another.example.com/foostyle.css")
        expect_stylesheet_url(@community, "#{@cdn}/foostyle.css")
      end
    end
  end
end
