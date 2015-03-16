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

      expect(c[:ident]).to eql "localfoodgarden"
      expect(c[:locales].first).to eql "es"
      expect(c[:country]).to eql "ES"
    end

    it "should find a free domain, if intitial domain is taken" do
      FactoryGirl.create(:community, :ident => "common")

      c = create(@community_params.merge!({:marketplace_name => "Common"}))
      expect(c[:ident]). to eql "common1"
    end

    it "should set correct currency based on contry selection" do
      c = create(@community_params)
      expect(c[:available_currencies]).to eql "EUR"

      c = create(@community_params.merge({:marketplace_country => "US"}))
      expect(c[:available_currencies]).to eql "USD"

      c = create(@community_params.merge({:marketplace_country => "GG"}))
      expect(c[:available_currencies]).to eql "GBP"
    end

    it "should set correct transaction_type and category" do
      community_hash = create(@community_params)
      c = Community.find(community_hash[:id])
      expect(c.transaction_types.first.price_field?).to eql true
      expect(c.transaction_types.first.price_per).to eql nil
      expect(c.transaction_types.first.price_quantity_placeholder).to eql nil

      community_hash = create(@community_params.merge({:marketplace_type => "rental"}))
      c = Community.find(community_hash[:id])
      expect(c.transaction_types.first.price_per).to eql "day"
      expect(c.transaction_types.first.price_field?).to eql true
      expect(c.transaction_types.first.price_quantity_placeholder).to eql nil

      community_hash = create(@community_params.merge({:marketplace_type => "service"}))
      c = Community.find(community_hash[:id])
      expect(c.transaction_types.first.price_per).to eql "day"
      expect(c.transaction_types.first.price_quantity_placeholder).to eql nil
      expect(c.transaction_types.first.price_field?).to eql true

      # check that category and transaction type are linked
      expect(c.transaction_types.first.categories.first).to eql c.categories.first
    end

    it "should have preauthorize_payments enabled" do
      community_hash = create(@community_params)
      c = Community.find(community_hash[:id])

      expect(c.transaction_types.pluck(:preauthorize_payment).all?).to be true
    end

    it "should have community customizations" do
      community_hash = create(@community_params)
      c = Community.find(community_hash[:id])

      expect(c.community_customizations.count).to eql 1
      expect(c.community_customizations.pluck(:locale).first).to eql "es"
    end

  end


end
