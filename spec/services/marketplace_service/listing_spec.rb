describe MarketplaceService::Listing::Entity do
  include MarketplaceService::Listing::Entity
  include MarketplaceService::Listing::Command

  it "#transaction_direction" do
    expect(transaction_direction("Rent")).to eq("offer")
    expect(transaction_direction("Request")).to eq("request")
    expect(transaction_direction("Inquiry")).to eq("inquiry")
    expect { transaction_direction("SellWithoutPayment") }.to raise_error
  end

  it "#discussion_type" do
    expect(discussion_type("Rent")).to eq("request")
    expect(discussion_type("Request")).to eq("offer")
    expect { discussion_type("Inquiry") }.to raise_error
    expect { discussion_type("SellWithoutPayment") }.to raise_error
  end

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
      expect(hammer.open).to be_false
      expect(hammer.deleted?).to be_true
    end
  end
end
