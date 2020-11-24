require 'spec_helper'

describe TransactionService::Order do
  let(:community) { FactoryGirl.create(:community) }

  before do
    request = OpenStruct.new
    request.session = {}
  end

  it "calculates the item total" do
    listing = FactoryGirl.create(:listing, price: Money.new(0, "USD"), community_id: community.id)
    tx_params = {quantity: 10}

    oder = TransactionService::Order.new(
      community: community,
      tx_params: tx_params,
      listing: listing)
    expect(oder.item_total).to eq(Money.new(0, "USD"))

    listing = FactoryGirl.create(:listing, price: Money.new(2500, "USD"), community_id: community.id)
    tx_params = {quantity: 10}

    oder = TransactionService::Order.new(
      community: community,
      tx_params: tx_params,
      listing: listing)
    expect(oder.item_total).to eq(Money.new(25_000, "USD"))

    tx_params = {quantity: 0}
    oder = TransactionService::Order.new(
      community: community,
      tx_params: tx_params,
      listing: listing)
    expect(oder.item_total).to eq(Money.new(0, "USD"))
  end

  it "calculates the shipping total" do
    listing = FactoryGirl.create(:listing, shipping_price: Money.new(5000, "USD"),
                                           shipping_price_additional: nil,
                                           community_id: community.id)
    tx_params = {quantity: 1, delivery: :shipping}

    oder = TransactionService::Order.new(
      community: community,
      tx_params: tx_params,
      listing: listing)
    expect(oder.shipping_total).to eq(Money.new(5000, "USD"))

    tx_params = {quantity: 10, delivery: :shipping}

    oder = TransactionService::Order.new(
      community: community,
      tx_params: tx_params,
      listing: listing)
    expect(oder.shipping_total).to eq(Money.new(5000, "USD"))

    listing = FactoryGirl.create(:listing, shipping_price: Money.new(5000, "USD"),
                                           shipping_price_additional: Money.new(1000, "USD"),
                                           community_id: community.id)
    tx_params = {quantity: 1, delivery: :shipping}

    oder = TransactionService::Order.new(
      community: community,
      tx_params: tx_params,
      listing: listing)
    expect(oder.shipping_total).to eq(Money.new(5000, "USD"))

    tx_params = {quantity: 5, delivery: :shipping}

    oder = TransactionService::Order.new(
      community: community,
      tx_params: tx_params,
      listing: listing)
    expect(oder.shipping_total).to eq(Money.new(9000, "USD"))
  end

  it "calculates the order total (item total + shipping total)" do
    listing = FactoryGirl.create(:listing,
                                 price: Money.new(25_000, "EUR"),
                                 shipping_price: Money.new(2_000, "EUR"),
                                 shipping_price_additional: Money.new(500, "EUR"),
                                 community_id: community.id)
    tx_params = {quantity: 5, delivery: :shipping}

    oder = TransactionService::Order.new(
      community: community,
      tx_params: tx_params,
      listing: listing)
    expect(oder.order_total).to eq(Money.new(129_000, "EUR"))
  end

  describe "buyer fee when stripe in use and paypal is not used" do
    let(:stripe_settings_without_buyer_fee) do
      FactoryGirl.create(:payment_settings,
                         community_id: community.id,
                         payment_gateway: 'stripe',
                         payment_process: :preauthorize,
                         active: true,
                         api_verified: true)
    end
    let(:stripe_settings_buyer_fee_relative) do
      FactoryGirl.create(:payment_settings,
                         community_id: community.id,
                         payment_gateway: 'stripe',
                         payment_process: :preauthorize,
                         active: true,
                         api_verified: true,
                         commission_from_buyer: 10)
    end
    let(:stripe_settings_buyer_fee_fixed) do
      FactoryGirl.create(:payment_settings,
                         community_id: community.id,
                         payment_gateway: 'stripe',
                         payment_process: :preauthorize,
                         active: true,
                         api_verified: true,
                         commission_from_buyer: 0,
                         minimum_buyer_transaction_fee_cents: 1000,
                         minimum_buyer_transaction_fee_currency: 'EUR')
    end
    let(:stripe_settings_buyer_fee_relative_and_fixed) do
      FactoryGirl.create(:payment_settings,
                         community_id: community.id,
                         payment_gateway: 'stripe',
                         payment_process: :preauthorize,
                         active: true,
                         api_verified: true,
                         commission_from_buyer: 10,
                         minimum_buyer_transaction_fee_cents: 1000,
                         minimum_buyer_transaction_fee_currency: 'EUR')
    end

    it "calculates the order total when buyer_fee is not present" do
      stripe_settings_without_buyer_fee
      listing = FactoryGirl.create(:listing, price: Money.new(5000, "EUR"), community_id: community.id)
      create_stripe_account(listing)
      tx_params = {quantity: 1}

      oder = TransactionService::Order.new(
        community: community,
        tx_params: tx_params,
        listing: listing)
      expect(oder.order_total).to eq(Money.new(5_000, "EUR"))
    end

    it "calculates the order total when buyer_fee is relative" do
      stripe_settings_buyer_fee_relative
      listing = FactoryGirl.create(:listing, price: Money.new(5000, "EUR"), community_id: community.id)
      create_stripe_account(listing)
      tx_params = {quantity: 1}

      oder = TransactionService::Order.new(
        community: community,
        tx_params: tx_params,
        listing: listing)
      expect(oder.order_total).to eq(Money.new(5_500, "EUR"))
    end

    it "calculates the order total when buyer_fee is fixed" do
      stripe_settings_buyer_fee_fixed
      listing = FactoryGirl.create(:listing, price: Money.new(5000, "EUR"), community_id: community.id)
      create_stripe_account(listing)
      tx_params = {quantity: 1}

      oder = TransactionService::Order.new(
        community: community,
        tx_params: tx_params,
        listing: listing)
      expect(oder.order_total).to eq(Money.new(6_000, "EUR"))
    end

    it "calculates the order total when buyer_fee is relative and fixed" do
      stripe_settings_buyer_fee_relative_and_fixed
      listing = FactoryGirl.create(:listing, price: Money.new(5000, "EUR"), community_id: community.id)
      create_stripe_account(listing)
      tx_params = {quantity: 1}

      oder = TransactionService::Order.new(
        community: community,
        tx_params: tx_params,
        listing: listing)
      expect(oder.buyer_fee).to eq(Money.new(1_000, "EUR"))
      expect(oder.order_total).to eq(Money.new(6_000, "EUR"))
    end

    def create_stripe_account(listing)
      FactoryGirl.create(:stripe_account,
                         community_id: community.id,
                         person_id: listing.author_id,
                         stripe_seller_id: 'abc',
                         stripe_bank_id: '123')
    end
  end
end
