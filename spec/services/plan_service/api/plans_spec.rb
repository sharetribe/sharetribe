require 'spec_helper'
# Override the API with test API
require_relative './api'

describe PlanService::API::Plans do

  before(:each) {
    PlanService::API::Api.reset!
  }

  context "external service in use" do
    let(:plans_api) {
      PlanService::API::Api.set_environment(active: true)
      PlanService::API::Api.plans
    }

    describe "#create" do
      context "#get_current" do
        it "creates a new initial trial" do
          Timecop.freeze(Time.now.change(usec: 0)) {
            expires_at = 1.month.from_now.change(usec: 0)

            plans_api.create_initial_trial(
              community_id: 123, plan: {
                status: :trial,
                expires_at: expires_at,
              })

            res = plans_api.get_current(community_id: 123)

            expect(res.success).to eq(true)
            expect(res.data[:id]).to be_a(Fixnum)
            expect(res.data.except(:id)).to include(
                                              community_id: 123,
                                              status: :trial,
                                              features: { deletable: true, admin_email: false, whitelabel: false },
                                              expires_at: expires_at,
                                              member_limit: 300,
                                              created_at: Time.now,
                                              updated_at: Time.now,
                                              expired: false,
                                            )

          }
        end

        it "creates a new plan" do
          Timecop.freeze(Time.now.change(usec: 0)) {
            expires_at = 1.month.from_now.change(usec: 0)

            plans_api.create(
              community_id: 123, plan: {
                status: :active,
                features: { whitelabel: true, admin_email: true },
                member_limit: 100000,
                expires_at: expires_at,
              })

            res = plans_api.get_current(community_id: 123)

            expect(res.success).to eq(true)
            expect(res.data[:id]).to be_a(Fixnum)
            expect(res.data.except(:id)).to include(
                                              community_id: 123,
                                              status: :active,
                                              features: { deletable: false, admin_email: true, whitelabel: true },
                                              member_limit: 100000,
                                              expires_at: expires_at,
                                              created_at: Time.now,
                                              updated_at: Time.now,
                                              expired: false,
                                            )

          }
        end

        it "creates a new plan that never expires" do
          Timecop.freeze(Time.now.change(usec: 0)) {
            plans_api.create(
              community_id: 123, plan: {
                status: :active,
                features: { whitelabel: true, admin_email: true },
                member_limit: 1000,
              })

            res = plans_api.get_current(community_id: 123)

            expect(res.success).to eq(true)
            expect(res.data[:id]).to be_a(Fixnum)
            expect(res.data.except(:id)).to include(
                                              community_id: 123,
                                              status: :active,
                                              features: { deletable: false, admin_email: true, whitelabel: true },
                                              member_limit: 1000,
                                              expires_at: nil,
                                              created_at: Time.now,
                                              updated_at: Time.now,
                                              expired: false,
                                            )
          }
        end
      end

      context "error" do
        it "raises error if both plan level and plan name are missing" do
          expect { plans_api.create(
            community_id: 123, plan: {
              expires_at: 1.month.from_now
            }) }.to raise_error(ArgumentError)
        end

        it "returns error if plan can not be found" do
          res = plans_api.get_current(community_id: 123)
          expect(res.success).to eq(false)
        end

        it "raises error if features is missing"do
          expect { plans_api.create(
            community_id: 123,
            plan: {
              status: :active,
              member_limit: 1000,
            }) }.to raise_error(ArgumentError)
        end

        it "raises error if status is missing"do
          expect { plans_api.create(
            community_id: 123,
            plan: {
              features: {whitelabel: :true},
              member_limit: 1000,
            }) }.to raise_error(ArgumentError)
        end
      end
    end

    describe "#get_external_service_link" do

      it "creates a link to external service with initial trial" do
        # First, create initial trial plan
        plans_api.create_initial_trial(community_id: 123, plan: {})

        link_res = plans_api.get_external_service_link(
          id: 123,
          ident: "marketplace",
          domain: "www.marketplace.com",
          marketplace_default_name: "Marketplace"
        )

        expect(link_res.success).to eq(true)
        expect(link_res.data.present?).to eq(true)
        expect(link_res.data).to be_a(String)

        # Improvement idea: decode the token and verify the correct data
      end

      it "creates a link to external service without initial trial" do
        link_res = plans_api.get_external_service_link(
          id: 123,
          ident: "marketplace",
          domain: "www.marketplace.com",
          marketplace_default_name: "Marketplace"
        )

        expect(link_res.success).to eq(true)
        expect(link_res.data.present?).to eq(true)
        expect(link_res.data).to be_a(String)

        # Improvement idea: decode the token and verify the correct data
      end

    end

    describe "#expired?" do
      it "returns false if plan never expires" do
        plan = plans_api.create(
          community_id: 111, plan: {
            status: :hold,
            features: { deletable: false, admin_email: true, whitelabel: true },
            expires_at: nil, # plan never expires
          }).data

        expect(plan[:expired]).to eq(false)
      end

      it "returns false if plan has not yet expired" do
        plan = plans_api.create(
          community_id: 111, plan: {
            status: :hold,
            features: { deletable: false, admin_email: true, whitelabel: true },
            expires_at: 1.month.from_now,
          }).data

        expect(plan[:expired]).to eq(false)
      end

      it "returns true if plan has expired" do
        plan = plans_api.create(
          community_id: 111, plan: {
            status: :hold,
            features: { deletable: false, admin_email: true, whitelabel: true },
            expires_at: 1.month.ago,
          }).data

        expect(plan[:expired]).to eq(true)
      end
    end

    describe "#closed?" do
      it "returns false, if plan has not expired" do
        plan = plans_api.create(
          community_id: 111, plan: {
            status: :active,
            features: { deletable: false, admin_email: true, whitelabel: true },
            expires_at: nil, # plan never expires
          }).data

        expect(plan[:expired]).to eq(false)
        expect(plan[:closed]).to eq(false)
      end

      it "returns false, if trial plan" do
        plan = plans_api.create(
          community_id: 111, plan: {
            status: :trial,
            features: { deletable: true, admin_email: false, whitelabel: false },
            expires_at: Time.now - 1.day,
          }).data

        expect(plan[:expired]).to eq(true)
        expect(plan[:closed]).to eq(false)
      end

      it "returns true, if non-trial plan has expired" do
        plan = plans_api.create(
          community_id: 111, plan: {
            status: :active,
            features: { deletable: false, admin_email: true, whitelabel: true },
            expires_at: Time.now - 1.day
          }).data

        expect(plan[:expired]).to eq(true)
        expect(plan[:closed]).to eq(true)
      end

      it "returns true, for hold plan" do
        plan = plans_api.create(
          community_id: 111, plan: {
            status: :hold,
            features: { deletable: false, admin_email: true, whitelabel: true },
            expires_at: nil
          }).data

        expect(plan[:expired]).to eq(false)
        expect(plan[:closed]).to eq(true)
      end
    end

  end


  context "external service not in use" do
    let(:plans_api) {
      PlanService::API::Api.set_environment(active: false)
      PlanService::API::Api.plans
    }

    it "does not creates a new initial trial" do
      res = plans_api.create_initial_trial(
        community_id: 123)

      expect(res.success).to eq(false)
    end

    it "does not creates a new plan" do
      res = plans_api.create(
        community_id: 123, plan: {})

      expect(res.success).to eq(false)
    end

    it "returns OS plan" do
      res = plans_api.get_current(community_id: 123)
      expect(res.success).to eq(true)
      expect(res.data).to include(
                       community_id: 123,
                       expires_at: nil,
                       expired: false
                     )
    end
  end

end
