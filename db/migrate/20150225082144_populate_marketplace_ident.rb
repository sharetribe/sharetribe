class PopulateMarketplaceIdent < ActiveRecord::Migration
  def up
    execute("UPDATE communities SET ident = domain")
  end

  def down
  end
end
