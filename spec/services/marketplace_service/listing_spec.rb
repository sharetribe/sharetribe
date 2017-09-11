require 'spec_helper'

describe Listing do

  describe "delete_listings" do
    let(:hammer) { FactoryGirl.create(:listing, title: "Hammer", listing_shape_id: 123)}
    let(:author) { hammer.author }

    it "delete_listings by author" do
      # Guard
      expect(hammer.deleted?).to eq(false)

      Listing.delete_by_author(author.id)
      hammer.reload

      expect(hammer.description).to be_nil
      expect(hammer.origin).to be_nil
      expect(hammer.open).to be false
      expect(hammer.deleted?).to be true
    end
  end
end
