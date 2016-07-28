class SetTypeForFeatureFlags < ActiveRecord::Migration
  def up
    # Set the type of every feature flag to CommunityFeatureFlag
    execute("
      UPDATE feature_flags
      SET type = 'CommunityFeatureFlag'
      ")
  end

  def down
    execute("
      UPDATE feature_flags
      SET type = NULL
      ")
  end
end
