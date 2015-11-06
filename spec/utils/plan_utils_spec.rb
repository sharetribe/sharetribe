require 'spec_helper'

describe PlanUtils do

  describe "#is_valid_plan_at_least?" do

    it "returns false for all expired plans" do
      plan = {expired: true, plan_level: PlanUtils::PRO}
      expect(PlanUtils.valid_plan_at_least?(plan, PlanUtils::PRO)).to eq(false)
    end

    it "returns false for valid plan if the level is not high enough" do
      plan = {expired: false, plan_level: PlanUtils::PRO}
      expect(PlanUtils.valid_plan_at_least?(plan, PlanUtils::SCALE)).to eq(false)
    end

    it "returns true for valid plan that is above the given level" do
      plan = {expired: false, plan_level: PlanUtils::PRO}
      expect(PlanUtils.valid_plan_at_least?(plan, PlanUtils::PRO)).to eq(true)
    end
  end
end
