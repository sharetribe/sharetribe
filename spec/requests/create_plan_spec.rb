require 'spec_helper'

# override the injector with test injector
require_relative 'external_plan_service_injector'

describe "plan provisioning" do

  let(:token) {
    # JWT.encode({}, "test_secret")
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.e30._FFJneyyiPmeCSEQdh2KPyIW84tXdjY1bhbc41LkRxw"
  }

  describe "security" do
    it "returns 401 if token doesn't match" do
      post "http://webhooks.sharetribe.com/webhooks/plans"
      expect(response.status).to eq(401)
    end

    it "returns 200 if authorized" do
      post "http://webhooks.sharetribe.com/webhooks/plans?token=#{token}"
      expect(response.status).to eq(200)
    end
  end
end
