require 'spec_helper'

describe StripeService::API::Accounts do
  let(:community) { FactoryGirl.create(:community) }
  let(:person) { FactoryGirl.create(:person, community_id: community.id) }

  describe '#delete_seller_account' do
    let(:unfinished_account) do
      FactoryGirl.create(:stripe_account,
                         community_id: community.id,
                         person_id: person.id)
    end
    let(:finished_account) do
      FactoryGirl.create(:stripe_account,
                         stripe_seller_id: 'acct_ABCDEFGHIJKLMOPR',
                         community_id: community.id,
                         person_id: person.id)
    end
    let(:payment_settings) do
      sk = TransactionService::Store::PaymentSettings.encrypt_value('sk_test_123456789012345678901234')
      FactoryGirl.create(:payment_settings,
                         community_id: community.id,
                         payment_gateway: 'stripe',
                         api_private_key: sk,
                         api_publishable_key: 'pk_test_123456789012345678901234')
    end

    before :each do
      payment_settings
    end

    it 'sucess if person does not have stripe account' do
      res = StripeService::API::Accounts.new.delete_seller_account(community_id: community.id,
                                                                   person_id: person.id)
      expect(res[:success]).to eq true
    end

    it 'sucess if person does have unfinished stripe account' do
      unfinished_account
      res = StripeService::API::Accounts.new.delete_seller_account(community_id: community.id,
                                                                   person_id: person.id)
      expect(res[:success]).to eq true
    end

    it 'if person does have finished stripe account' do
      finished_account

      stub_stripe_success
      res = StripeService::API::Accounts.new.delete_seller_account(community_id: community.id,
                                                                   person_id: person.id)
      expect(res[:success]).to eq true
    end

    it 'should fail if person does have finished stripe account
      and stripe does not allow to delete account' do
      finished_account

      stub_stripe_failure
      res = StripeService::API::Accounts.new.delete_seller_account(community_id: community.id,
                                                                   person_id: person.id)
      expect(res[:success]).to eq false
    end

    def stub_stripe_success
      account = double(:StripeAccount)
      allow(account).to receive(:delete).and_return({
        "id": "acct_ABCDEFGHIJKLMOPR",
        "deleted": true
      })
      api = double(:StripeAccountApi)
      allow(api).to receive(:retrieve).with(anything).and_return(account)
      stub_const('Stripe::Account', api)
    end

    def stub_stripe_failure
      account = double(:StripeAccount)
      allow(account).to receive(:delete).and_raise(StandardError.new('Stripe error'))
      api = double(:StripeAccountApi)
      allow(api).to receive(:retrieve).with(anything).and_return(account)
      stub_const('Stripe::Account', api)
    end
  end
end
