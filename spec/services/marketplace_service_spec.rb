require 'spec_helper'

describe MarketplaceService do
  include MarketplaceService

  describe "#create" do

    before :each do
      @community_params = {
        :marketplace_name => "LocalFoodGarden",
        :marketplace_type => "product",
        :marketplace_country => "ES",
        :marketplace_language => "es"
      }
    end

    it "should create a marketplace" do
      c = create(@community_params)

      expect(c.ident).to eql "localfoodgarden"
      expect(c.locales.first).to eql "es"
      expect(c.country).to eql "ES"
    end

    it "should find a free domain, if intitial domain is taken" do
      FactoryGirl.create(:community, :ident => "common")

      c = create(@community_params.merge!({:marketplace_name => "Common"}))
      expect(c.ident). to eql "common1"
    end

    it "should set correct currency based on contry selection" do
      c = create(@community_params)
      expect(c.currency).to eql "EUR"

      c = create(@community_params.merge({:marketplace_country => "US"}))
      expect(c.currency).to eql "USD"

      c = create(@community_params.merge({:marketplace_country => "GG"}))
      expect(c.currency).to eql "GBP"
    end

    it "should set correct listing shape and category" do
      community = create(@community_params)
      c = Community.find(community.id)
      s = c.shapes.first
      expect(s.units.empty?).to eql false
      default_per_unit = {kind: "quantity", name_tr_key: nil, quantity_selector: "number", selector_tr_key: nil, unit_type: "unit"}
      expect(s.units.first).to eql default_per_unit
      expect(s.availability).to eql 'none'
      expect(s.price_enabled).to eql true
      expect(s.shipping_enabled).to eql true

      community = create(@community_params.merge({:marketplace_type => "rental"}))
      c = Community.find(community.id)
      s = c.shapes.last
      expect(s.availability).to eql 'booking'
      expect(s.units[0][:unit_type]).to eql 'night'
      expect(s.price_enabled).to eql true
      expect(s.shipping_enabled).to eql false

      community = create(@community_params.merge({:marketplace_type => "service"}))
      c = Community.find(community.id)
      s = c.shapes.last
      expect(s.availability).to eql 'booking'
      expect(s.units[0][:unit_type]).to eql 'hour'
      expect(s.price_enabled).to eql true
      expect(s.shipping_enabled).to eql false

      # check that category and shape are linked
      expect(CategoryListingShape.where(listing_shape_id: s[:id]).count).to eq(1)
      expect(CategoryListingShape.where(listing_shape_id: s[:id]).first.category).to eql c.categories.first
    end

    it "should have preauthorize_payments enabled" do
      community = create(@community_params)
      c = Community.find(community.id)
      processes = TransactionService::API::Api.processes
                  .get(community_id: c.id).data
        .map { |p| {:author_is_seller => p.author_is_seller, :process => p.process} }
      expect(processes.size).to eq 3
      expect(processes.include?({ author_is_seller: true, process: :preauthorize})).to eq true
      expect(processes.include?({ author_is_seller: false, process: :none})).to eq true
      expect(processes.include?({ author_is_seller: true, process: :none})).to eq true
    end

    it "should create marketplace without payment process" do
      community = create(@community_params.merge(payment_process: :none))
      c = Community.find(community.id)
      processes = TransactionService::API::Api.processes
                  .get(community_id: c.id).data
        .map { |p| {:author_is_seller => p.author_is_seller, :process => p.process} }
      expect(processes.size).to eq 2
      expect(processes.include?({ author_is_seller: false, process: :none})).to eq true
      expect(processes.include?({ author_is_seller: true, process: :none})).to eq true
    end

    it "should have community customizations" do
      community = create(@community_params)
      c = Community.find(community.id)

      expect(c.community_customizations.count).to eql 1
      expect(c.community_customizations.pluck(:locale).first).to eql "es"
    end

  end


end
