class PopulateRedirectToDomain < ActiveRecord::Migration[5.2]
def up
    execute("UPDATE communities SET redirect_to_domain = true WHERE domain IS NOT NULL")
  end

  def down
    execute("UPDATE communities SET redirect_to_domain = false")
  end
end
