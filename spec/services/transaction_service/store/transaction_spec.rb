require 'spec_helper'

describe TransactionService::Store::Transaction do

  PaypalAccountModel = ::PaypalAccount
  TransactionStore = TransactionService::Store::Transaction
  TransactionModel = ::Transaction

  before(:each) do
    @cid = 3
    @payer = FactoryGirl.create(:payer)
    @listing = FactoryGirl.create(:listing,
                                  price: Money.new(45000, "EUR"),
                                  listing_shape_id: 123, # This is not used, but needed because the Entity value is mandatory
                                  transaction_process_id: 123) # This is not used, but needed because the Entity value is mandatory

    @paypal_account = PaypalAccountModel.create(person_id: @listing.author, community_id: @cid, email: "author@sharetribe.com", payer_id: "abcdabcd")

    @transaction_info = {
      payment_process: :preauthorize,
      payment_gateway: :paypal,
      community_id: @cid,
      starter_id: @payer.id,
      listing_id: @listing.id,
      listing_title: @listing.title,
      unit_price: @listing.price,
      listing_author_id: @listing.author_id,
      listing_quantity: 1,
      automatic_confirmation_after_days: 3,
      commission_from_seller: 10,
      minimum_commission: Money.new(20, "EUR")
    }
  end

  context "#create" do
    it "creates transactions with deleted set to false" do
      tx = TransactionStore.create(@transaction_info)

      expect(tx).not_to be_nil
      expect(TransactionModel.first.deleted).to eq(false)
      expect(TransactionStore.get(tx[:id])).not_to be_nil
    end
  end

  context "#delete" do
    it "sets deleted flag for the given transaction_id" do
      tx = TransactionStore.create(@transaction_info)
      TransactionStore.delete(community_id: tx[:community_id], transaction_id: tx[:id])
      expect(TransactionModel.first.deleted).to eq(true)
    end

    it "deleted transaction are not returned by get" do
      tx = TransactionStore.create(@transaction_info)
      TransactionStore.delete(community_id: tx[:community_id], transaction_id: tx[:id])
      expect(TransactionStore.get(tx[:id])).to be_nil
    end

    it "deleted transaction are not returned by get_in_community" do
      tx = TransactionStore.create(@transaction_info)
      TransactionStore.delete(community_id: tx[:community_id], transaction_id: tx[:id])
      expect(TransactionStore.get_in_community(community_id: tx[:community_id], transaction_id: tx[:id])).to be_nil
    end
  end
end
