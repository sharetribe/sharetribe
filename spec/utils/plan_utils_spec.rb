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

  describe "#expired? and valid?" do
    it "returns true for expired plan, false for valid plans" do
      expired = {expired: true, plan_level: PlanUtils::PRO}
      valid = {expired: false, plan_level: PlanUtils::PRO}

      expect(PlanUtils.expired?(expired)).to eq(true)
      expect(PlanUtils.expired?(valid)).to eq(false)
      expect(PlanUtils.expired?(nil)).to eq(false)
      expect(PlanUtils.valid?(expired)).to eq(false)
      expect(PlanUtils.valid?(valid)).to eq(true)
      expect(PlanUtils.valid?(nil)).to eq(false)
    end
  end

end
