describe MarketplaceService::Listing::Entity do
  include MarketplaceService::Listing::Entity

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
end
