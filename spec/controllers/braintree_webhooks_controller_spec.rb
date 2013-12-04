require 'spec_helper'

describe BraintreeWebhooksController do
  before(:each) do
    @community = FactoryGirl.create(:community, :domain => "market.custom.org")
    braintree_payment_gateway = PaymentGateway.find_by_type("BraintreePaymentGateway")
    FactoryGirl.create(:community_payment_gateway, :community => @community, :payment_gateway => braintree_payment_gateway)

    # Refresh from DB
    @community.reload

    # Guard assert
    @community.braintree_in_use?.should be_true

    request.host = "market.custom.org"
  end

  describe "#hooks" do

    it "rescues from error" do
      # Prepare
      @person = FactoryGirl.create(:person, :id => "123abc")

      # TODO Move these
      Braintree::Configuration.environment = :sandbox
      Braintree::Configuration.merchant_id = "vyhwdzxmbvw64z8v"
      Braintree::Configuration.public_key = "fp654nr3qzzz5k78"
      Braintree::Configuration.private_key = "119c7481abe69f6e4c1ca1d3d8ad17e3"

      signature, payload = BraintreeService.webhook_testing_sample_notification(
        @community,
        Braintree::WebhookNotification::Kind::SubMerchantAccountApproved,
        @person.id
      )

      post :hooks, :bt_signature => "#{signature}-invalid", :bt_payload => payload

      response.status.should == 400
    end

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
        post :hooks, :bt_signature => signature, :bt_payload => payload

        # Assert
        BraintreeAccount.find_by_person_id(@person.id).status.should == "active"
      end

      it "listens for SubMerchantAccountDeclined" do
        signature, payload = BraintreeService.webhook_testing_sample_notification(
          @community,
          Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined,
          @person.id
        )

        # Do
        post :hooks, :bt_signature => signature, :bt_payload => payload

        # Assert
        BraintreeAccount.find_by_person_id(@person.id).status.should == "suspended"
      end
    end
  end
end