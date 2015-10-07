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

      plan1234 = PlanService::API::Api.plans.get_current(community_id: 1234).data

      expect(plan1234.slice(:community_id, :plan_level, :expires_at)).to eq({
                               community_id: 1234,
                               plan_level: 2,
                               expires_at: nil
                             })

      plan5555 = PlanService::API::Api.plans.get_current(community_id: 5555)
                 .data

      expect(plan5555.slice(:community_id, :plan_level, :expires_at)).to eq({
                               community_id: 5555,
                               plan_level: 5,
                               expires_at: Time.utc(2015, 10, 15, 15, 0, 0)
                             })

      expect(response.status).to eq(200)
      expect(response.body).to eq({
                                    plans: [
                                      {marketplace_plan_id: plan1234[:id]},
                                      {marketplace_plan_id: plan5555[:id]}
                                    ]
                                  }.to_json)
    end
  end

  describe "trials" do

    it "fetches trials after given time" do
      id111 = nil
      id222 = nil
      id333 = nil

      Timecop.freeze(Time.utc(2015, 9, 15)) {
        id111 = PlanService::API::Api.plans.create(community_id: 111, plan: {plan_level: 0}).data[:id]
      }

      Timecop.freeze(Time.utc(2015, 10, 15)) {
        id222 = PlanService::API::Api.plans.create(community_id: 222, plan: {plan_level: 0}).data[:id]
      }

      Timecop.freeze(Time.utc(2015, 11, 15)) {
        id333 = PlanService::API::Api.plans.create(community_id: 333, plan: {plan_level: 0}).data[:id]
      }

      after = Time.utc(2015, 10, 1).to_i

      get "http://webhooks.sharetribe.com/webhooks/trials?token=#{token}&after=#{after}"

      puts response.body

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body))
        .to eq(JSON.parse({
                            plans: [
                              {
                                marketplace_plan_id: id222,
                                marketplace_id: 222,
                                plan_level: 0,
                                created_at: Time.utc(2015, 10, 15),
                                updated_at: Time.utc(2015, 10, 15),
                                expires_at: nil,
                              },
                              {
                                marketplace_plan_id: id333,
                                marketplace_id: 333,
                                plan_level: 0,
                                created_at: Time.utc(2015, 11, 15),
                                updated_at: Time.utc(2015, 11, 15),
                                expires_at: nil,
                              }
                            ]
                          }.to_json))

    end

  end
end
