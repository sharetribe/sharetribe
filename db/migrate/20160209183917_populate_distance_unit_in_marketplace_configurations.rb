class PopulateDistanceUnitInMarketplaceConfigurations < ActiveRecord::Migration
  def up
    # Run this population script after all the codes are in production
    execute("
      UPDATE marketplace_configurations mc, communities c
        SET mc.distance_unit = 'imperial'
        WHERE mc.community_id = c.id AND c.country = 'US';
    ")
  end

  def down
    # These kind of settings should not be changed when rolling back migrations.
    # Admins might have changed them already
  end
end
