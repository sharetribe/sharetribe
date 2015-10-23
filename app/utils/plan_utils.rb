
# Utility module to help working with the
# PlanService responses
#
module PlanUtils

  FREE = 0
  STARTER = 1
  PRO = 2
  GROWTH = 3
  SCALE = 4
  HOLD = 5
  OS = 99999

  module_function

  def valid_plan_at_least?(plan, level)
    # FIXME, wrong result for hold plan
    valid?(plan) && plan[:plan_level] >= level
  end

  def expired?(plan)
    plan.present? && plan[:expired]
  end

  def valid?(plan)
    plan.present? && !plan[:expired]
  end

end
