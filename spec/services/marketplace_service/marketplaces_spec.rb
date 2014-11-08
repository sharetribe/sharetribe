describe MarketplaceService::API::Marketplaces do
  include MarketplaceService::API::Marketplaces

  describe "#create" do
    before (:each) do
      @community_params = {
        :marketplace_name => "LocalFoodGarden",
        :marketplace_type => "product",
        :marketplace_country => "ES",
        :marketplace_language => "es"
      }
    end

    it "should create a marketplace" do

      c = create(@community_params)

      expect(c.domain).to eql "localfoodgarden"
      expect(c.locales.first).to eql "es"
      expect(c.country).to eql "ES"


    end

    it "should find a free domain, if intitial domain is taken" do
      FactoryGirl.create(:community, :domain => "common")

      c = create(@community_params.merge!({:marketplace_name => "Common"}))
      expect(c.domain). to eql "common1"
    end

    it "should set correct currency based on contry selection" do
      c = create(@community_params)
      expect(c.available_currencies).to eql "EUR"

      c = create(@community_params.merge({:marketplace_country => "US"}))
      expect(c.available_currencies).to eql "USD"

      c = create(@community_params.merge({:marketplace_country => "GG"}))
      expect(c.available_currencies).to eql "GBP"


    end

    it "should set correct transaction_type and category" do
      c = create(@community_params)
      expect(c.transaction_types.first.class).to eql Sell

      c = create(@community_params.merge({:marketplace_type => "rental"}))
      expect(c.transaction_types.first.class).to eql Rent

      c = create(@community_params.merge({:marketplace_type => "service"}))
      expect(c.transaction_types.first.class).to eql Service
    end

  end


end
