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
      post "http://webhooks.sharetribe.com/webhooks/plans", "{}"
      expect(response.status).to eq(401)
    end

    it "returns 200 if authorized" do
      post "http://webhooks.sharetribe.com/webhooks/plans?token=#{token}", "{}"
      expect(response.status).to eq(200)
    end
  end

  describe "invalid JSON" do
    it "returns 400 Bad request, if JSON is invalid" do
      post "http://webhooks.sharetribe.com/webhooks/plans?token=#{token}", "invalid JSON"
      expect(response.status).to eq(400)
    end
  end

  describe "plans" do

    it "creates new plans" do
      body = '{
        "plans": [
          {
            "marketplace_id": 1234,
            "plan_level": 2
          },
          {
            "marketplace_id": 5555,
            "plan_level": 5,
            "expires_at": "2015-10-15 15:00:00"
          }
        ]
      }'

      post "http://webhooks.sharetribe.com/webhooks/plans?token=#{token}", body

      plan1234 = PlanService::API::Api.plans.get_current(community_id: 1234)
                 .data
                 .slice(:community_id, :plan_level, :expires_at)

      expect(plan1234).to eq({
                               community_id: 1234,
                               plan_level: 2,
                               expires_at: nil
                             })

      plan5555 = PlanService::API::Api.plans.get_current(community_id: 5555)
                 .data
                 .slice(:community_id, :plan_level, :expires_at)

      expect(plan5555).to eq({
                               community_id: 5555,
                               plan_level: 5,
                               expires_at: Time.utc(2015, 10, 15, 15, 0, 0)
                             })
    end
  end
end
