require 'spec_helper'

describe Checkout do
  let(:gateway) { FactoryGirl.build(:checkout_payment_gateway) }

  describe "#configured?" do

    it "is not configured" do
      gateway.checkout_environment = "production"
      gateway.checkout_user_id = ""
      gateway.checkout_password = ""

      gateway.configured?.should be_false
    end

    it "is configured if it's in testing mode" do
      gateway.checkout_environment = "stub"
      gateway.checkout_user_id = ""
      gateway.checkout_password = ""

      gateway.configured?.should be_true
    end

    it "production and configured" do
      gateway.checkout_environment = "production"
      gateway.checkout_user_id = "1234user"
      gateway.checkout_password = "xxxxyyyyyzzzzz"

      gateway.configured?.should be_true
    end
  end
end