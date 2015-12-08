class DropCommunityPlans < ActiveRecord::Migration
  def up
    drop_table :community_plans
  end

  def down
    create_table "community_plans" do |t|
      t.integer  "community_id",                :null => false
      t.integer  "plan_level",   :default => 0, :null => false
      t.datetime "expires_at"
      t.datetime "created_at",                  :null => false
      t.datetime "updated_at",                  :null => false
    end
  end
end
