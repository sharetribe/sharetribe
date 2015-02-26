class PopulateMarketplaceUsername < ActiveRecord::Migration
  def up
    execute("UPDATE communities SET username = domain")
  end

  def down
  end
end
