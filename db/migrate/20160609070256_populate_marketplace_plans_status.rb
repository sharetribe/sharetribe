class PopulateMarketplacePlansStatus < ActiveRecord::Migration
  def up
    exec_update("UPDATE marketplace_plans SET status = 'trial' WHERE plan_level = 0", "Set trial status", [])
    exec_update("UPDATE marketplace_plans SET status = 'hold' WHERE plan_level = 5", "Set hold status", [])
    exec_update("UPDATE marketplace_plans SET status = 'active' WHERE plan_level != 0 AND plan_level != 5", "Set active status", [])
  end

  def down
    exec_update("UPDATE marketplace_plans SET status = NULL", "Remove status", [])
  end
end
