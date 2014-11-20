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

describe Checkout do
  let(:gateway) { FactoryGirl.build(:checkout_payment_gateway) }

  describe "#configured?" do

    it "is not configured" do
      gateway.checkout_environment = "production"
      gateway.checkout_user_id = ""
      gateway.checkout_password = ""

      gateway.configured?.should be_falsey
    end

    it "is configured if it's in testing mode" do
      gateway.checkout_environment = "stub"
      gateway.checkout_user_id = ""
      gateway.checkout_password = ""

      gateway.configured?.should be_truthy
    end

    it "production and configured" do
      gateway.checkout_environment = "production"
      gateway.checkout_user_id = "1234user"
      gateway.checkout_password = "xxxxyyyyyzzzzz"

      gateway.configured?.should be_truthy
    end
  end
end
