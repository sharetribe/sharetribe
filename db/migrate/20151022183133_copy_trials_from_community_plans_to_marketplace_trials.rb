class CopyTrialsFromCommunityPlansToMarketplaceTrials < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO marketplace_trials (community_id, expires_at, created_at, updated_at)
        (SELECT community_id, expires_at, created_at, updated_at
         FROM community_plans
         WHERE plan_level = 0)
    ")
  end

  def down
    execute("
      DELETE FROM marketplace_trials
    ")
  end
end
