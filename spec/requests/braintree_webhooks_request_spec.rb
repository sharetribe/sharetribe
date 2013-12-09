require 'spec_helper'

#
# Integration tests for Braintree Webhooks URLs/routes
#
# Do not test all the edge cases here! Test them in controller spec. Here
# you should only test that the routing works properly and external HTTP calls
# to braintree webhook URL is working ok.
# 

describe "braintree webhooks" do
  before(:each) do
    @community = FactoryGirl.create(:community, :domain => "market.custom.org")
    braintree_payment_gateway = PaymentGateway.find_by_type("BraintreePaymentGateway")
    FactoryGirl.create(:community_payment_gateway, :community => @community, :payment_gateway => braintree_payment_gateway)

    # Refresh from DB
    @community.reload

    # Guard assert
    @community.braintree_in_use?.should be_true
  end

  describe "#challenge" do
    it "returns 200 for challenge" do
      get "http://market.custom.org/webhooks/braintree"

      response.status.should == 200

      # The response format seems to be 16 random chars, pipe '|' and 40 random chars
      first_part, last_part = response.body.split("|")
      first_part.length.should be_equal 16
      last_part.length.should be_equal 40
    end

    it "returns 400 Bad Request if community doesn't have Braintree" do
      @community.payment_gateways = []
      @community.save!

      # Guard assert
      @community.braintree_in_use?.should be_false

      get "http://market.custom.org/webhooks/braintree"

      response.status.should == 400
    end
  end

  describe "#hooks" do

    describe "account creation hooks" do
      before(:each) do
        # Prepare
        @person = FactoryGirl.create(:person, :id => "123abc")
        @braintree_account = FactoryGirl.create(:braintree_account, :person => @person, :status => "pending")

        # Guard assert
        BraintreeAccount.find_by_person_id(@person.id).status.should == "pending"
      end

      it "listens for SubMerchantAccountApproved" do
        signature, payload = BraintreeService.webhook_testing_sample_notification(
          @community,
          Braintree::WebhookNotification::Kind::SubMerchantAccountApproved,
          @person.id
        )

        # Do
        post "http://market.custom.org/webhooks/braintree", :bt_signature => signature, :bt_payload => payload

        # Assert
        BraintreeAccount.find_by_person_id(@person.id).status.should == "active"
      end
    end
  end
end