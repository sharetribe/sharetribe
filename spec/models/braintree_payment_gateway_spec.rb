require 'spec_helper'

describe BraintreePaymentGateway do
  let(:gateway) { FactoryGirl.build(:braintree_payment_gateway) }

  describe "#configured?" do

    it "is not configured" do
      gateway.braintree_environment = "production"
      gateway.braintree_merchant_id = nil
      gateway.braintree_master_merchant_id = nil
      gateway.braintree_public_key = nil
      gateway.braintree_private_key = nil
      gateway.braintree_client_side_encryption_key = "xxx"

      gateway.configured?.should be_false
    end

    it "is configured" do
      gateway.braintree_environment = "production"
      gateway.braintree_merchant_id = "merchant123"
      gateway.braintree_master_merchant_id = "mastermerchant_123"
      gateway.braintree_public_key = "1252384a99cdb1"
      gateway.braintree_private_key = "1252384a99cdb1"
      gateway.braintree_client_side_encryption_key = "xxx"

      gateway.configured?.should be_true
    end
  end
end