require 'spec_helper'

describe MarketplaceService::Listing::Entity do
  include MarketplaceService::Listing::Entity
  include MarketplaceService::Listing::Command

  describe "delete_listings" do
    let(:hammer) { FactoryGirl.create(:listing, title: "Hammer")}
    let(:author) { hammer.author }

    it "delete_listings by author" do
      # Guard
      expect(hammer.deleted?).to eq(false)

      delete_listings(author.id)
      hammer.reload

      expect(hammer.description).to be_nil
      expect(hammer.origin).to be_nil
      expect(hammer.open).to be false
      expect(hammer.deleted?).to be true
    end
  end
end
