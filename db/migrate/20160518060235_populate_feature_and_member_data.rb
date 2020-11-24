class PopulateFeatureAndMemberData < ActiveRecord::Migration
  def up
    exec_update(
      "UPDATE marketplace_plans mp
       JOIN (
          SELECT 0 AS plan_level, '{\"deletable\":true,\"admin_email\":false,\"whitelabel\":true}' AS features
          UNION ALL
          SELECT 1 AS plan_level, '{\"deletable\":false,\"admin_email\":false,\"whitelabel\":true}' AS features
          UNION ALL
          SELECT 2 AS plan_level, '{\"deletable\":false,\"admin_email\":true,\"whitelabel\":true}' AS features
          UNION ALL
          SELECT 3 AS plan_level, '{\"deletable\":false,\"admin_email\":true,\"whitelabel\":true}' AS features
          UNION ALL
          SELECT 4 AS plan_level, '{\"deletable\":false,\"admin_email\":true,\"whitelabel\":true}' AS features
          UNION ALL
          SELECT 999 AS plan_level, '{\"deletable\":true,\"admin_email\":true,\"whitelabel\":true}' AS features
       ) f
       ON mp.plan_level = f.plan_level
       SET mp.features = f.features
      ",
      "Set features", [])

    exec_update(
      "UPDATE marketplace_plans mp
       JOIN (
          SELECT 0 AS plan_level, 300 AS member_limit
          UNION ALL
          SELECT 1 AS plan_level, 300 AS member_limit
          UNION ALL
          SELECT 2 AS plan_level, 1000 AS member_limit
          UNION ALL
          SELECT 3 AS plan_level, 10000 AS member_limit
          UNION ALL
          SELECT 4 AS plan_level, 100000 AS member_limit
          UNION ALL
          SELECT 999 AS plan_level, NULL AS member_limit
       ) f
       ON mp.plan_level = f.plan_level
       SET mp.member_limit = f.member_limit
      ",
      "Set member limit", [])
  end

  def down
    # no-op, we don't want to lose data
  end
end
