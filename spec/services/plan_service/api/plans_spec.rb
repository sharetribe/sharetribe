describe PlanService::API::Plans do

  context "external service in use" do
    let(:plans) { PlanService::API::Plans.new(active: true) }

    describe "#create" do
      context "#get_current" do
        it "creates a new initial trial" do
          Timecop.freeze(Time.now.change(usec: 0)) {
            expires_at = 1.month.from_now.change(usec: 0)

            plans.create_initial_trial(
              community_id: 123, plan: {
                plan_level: PlanService::Levels::FREE,
                expires_at: expires_at,
              })

            res = plans.get_current(community_id: 123)

            expect(res.success).to eq(true)
            expect(res.data[:id]).to be_a(Fixnum)
            expect(res.data.except(:id)).to eq(
                                              community_id: 123,
                                              plan_level: 0,
                                              expires_at: expires_at,
                                              created_at: Time.now,
                                              updated_at: Time.now,
                                              expired: false,
                                            )

          }
        end

        it "creates a new plan" do
          Timecop.freeze(Time.now.change(usec: 0)) {
            expires_at = 1.month.from_now.change(usec: 0)

            plans.create(
              community_id: 123, plan: {
                plan_level: PlanService::Levels::SCALE,
                expires_at: expires_at,
              })

            res = plans.get_current(community_id: 123)

            expect(res.success).to eq(true)
            expect(res.data[:id]).to be_a(Fixnum)
            expect(res.data.except(:id)).to eq(
                                              community_id: 123,
                                              plan_level: 4,
                                              expires_at: expires_at,
                                              created_at: Time.now,
                                              updated_at: Time.now,
                                              expired: false,
                                            )

          }
        end

        it "creates a new plan that never expires" do
          Timecop.freeze(Time.now.change(usec: 0)) {
            plans.create(
              community_id: 123, plan: {
                plan_level: PlanService::Levels::PRO
              })

            res = plans.get_current(community_id: 123)

            expect(res.success).to eq(true)
            expect(res.data[:id]).to be_a(Fixnum)
            expect(res.data.except(:id)).to eq(
                                              community_id: 123,
                                              plan_level: 2,
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
          expect { plans.create(
            community_id: 123, plan: {
              expires_at: 1.month.from_now
            }) }.to raise_error(ArgumentError)
        end

        it "returns error if plan can not be found" do
          res = plans.get_current(community_id: 123)
          expect(res.success).to eq(false)
        end
      end
    end

    describe "#expired?" do
      context "success" do
        it "returns false if plan never expires" do
          plans.create(
            community_id: 111, plan: {
              plan_level: 5,
              expires_at: nil, # plan never expires
            })

          res = plans.expired?(community_id: 111).data
          expect(res).to eq(false)
        end

        it "returns false if plan has not yet expired" do
          plans.create(
            community_id: 111, plan: {
              plan_level: 5,
              expires_at: 1.month.from_now,
            })

          res = plans.expired?(community_id: 111).data
          expect(res).to eq(false)
        end

        it "returns true if plan has expired" do
          plans.create(
            community_id: 111, plan: {
              plan_level: 5,
              expires_at: 1.month.ago,
            })

          res = plans.expired?(community_id: 111).data
          expect(res).to eq(true)
        end
      end

      context "error" do
        it "returns error if plan can not be found" do
          res = plans.get_current(community_id: 123)
          expect(res.success).to eq(false)
        end
      end
    end

  end


  context "external service not in use" do
    let(:plans) { PlanService::API::Plans.new(active: false) }

    it "does not creates a new initial trial" do
      res = plans.create_initial_trial(
        community_id: 123, plan: {
          plan_level: PlanService::Levels::FREE,
        })

      expect(res.success).to eq(false)
    end

    it "does not creates a new plan" do
      res = plans.create(
        community_id: 123, plan: {
          plan_level: PlanService::Levels::SCALE,
        })

      expect(res.success).to eq(false)
    end

    it "returns OS plan" do
      res = plans.get_current(community_id: 123)
      expect(res.success).to eq(true)
      expect(res.data).to include(
                       plan_level: 99999,
                       community_id: 123,
                       expires_at: nil
                     )
    end

    it "never expires" do
      res = plans.expired?(community_id: 123)
      expect(res.success).to eq(true)
      expect(res.data).to eq(false)
    end
  end

end
