# == Schema Information
#
# Table name: payment_gateways
#
#  id                                   :integer          not null, primary key
#  community_id                         :integer
#  type                                 :string(255)
#  braintree_environment                :string(255)
#  braintree_merchant_id                :string(255)
#  braintree_master_merchant_id         :string(255)
#  braintree_public_key                 :string(255)
#  braintree_private_key                :string(255)
#  braintree_client_side_encryption_key :text
#  checkout_environment                 :string(255)
#  checkout_user_id                     :string(255)
#  checkout_password                    :string(255)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

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

      gateway.configured?.should be_falsey
    end

    it "is configured" do
      gateway.braintree_environment = "production"
      gateway.braintree_merchant_id = "merchant123"
      gateway.braintree_master_merchant_id = "mastermerchant_123"
      gateway.braintree_public_key = "1252384a99cdb1"
      gateway.braintree_private_key = "1252384a99cdb1"
      gateway.braintree_client_side_encryption_key = "xxx"

      gateway.configured?.should be_truthy
    end
  end
end
