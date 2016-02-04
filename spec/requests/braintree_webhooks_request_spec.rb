require 'spec_helper'

#
# Integration tests for Braintree Webhooks URLs/routes
#
# Do not test all the edge cases here! Test them in controller spec. Here
# you should only test that the routing works properly and external HTTP calls
# to braintree webhook URL is working ok.
#

describe "braintree webhooks", type: :request do
  before(:each) do
    @community = FactoryGirl.create(:community, :domain => "market.custom.org", use_domain: true)
    FactoryGirl.create(:braintree_payment_gateway, :community => @community, :type => "BraintreePaymentGateway")

    # Refresh from DB
    @community.reload

    # Guard assert
    expect(@community.braintree_in_use?).to be_truthy
  end

  describe "#challenge" do
    it "returns 200 for challenge" do
      get "http://market.custom.org/webhooks/braintree", :community_id => @community.id

      expect(response.status).to eq(200)

      # The response format seems to be 16 random chars, pipe '|' and 40 random chars
      first_part, last_part = response.body.split("|")
      expect(first_part.length).to be_equal 16
      expect(last_part.length).to be_equal 40
    end

    it "returns 400 Bad Request if community doesn't have Braintree" do
      @community.payment_gateway = nil
      @community.save!

      # Guard assert
      expect(@community.braintree_in_use?).to be_falsey

      get "http://market.custom.org/webhooks/braintree", :community_id => @community.id

      expect(response.status).to eq(400)
    end
  end

  describe "#hooks" do

    describe "account creation hooks" do
      before(:each) do
        # Prepare
        @person = FactoryGirl.create(:person, :id => "123abc")
        @braintree_account = FactoryGirl.create(:braintree_account, :person => @person, :status => "pending")

        # Guard assert
        expect(BraintreeAccount.find_by_person_id(@person.id).status).to eq("pending")
      end

      it "listens for SubMerchantAccountApproved" do
        signature, payload = BraintreeApi.webhook_testing_sample_notification(
          @community,
          Braintree::WebhookNotification::Kind::SubMerchantAccountApproved,
          @person.id
        )

        # Do
        post "http://market.custom.org/webhooks/braintree", :bt_signature => signature, :bt_payload => payload, :community_id => @community.id

        # Assert
        expect(BraintreeAccount.find_by_person_id(@person.id).status).to eq("active")
      end
    end
  end
end
