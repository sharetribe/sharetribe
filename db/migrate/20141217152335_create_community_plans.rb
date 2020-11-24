class CreateCommunityPlans < ActiveRecord::Migration
  def up
    create_table :community_plans do |t|
      t.string   :community_id,             null: false
      t.integer  :plan_level,   default: 0, null: false
      t.datetime :expires_at,               null: true

      t.timestamps
    end
    # Insert plan levels for correct communities
    execute "INSERT INTO community_plans(community_id, plan_level, created_at, updated_at) SELECT communities.id AS community_id, communities.plan_level, NOW(), NOW() FROM communities"

  end

  def down
    drop_table :community_plans
  end
end
