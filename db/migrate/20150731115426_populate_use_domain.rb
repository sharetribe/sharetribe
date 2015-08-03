class PopulateUseDomain < ActiveRecord::Migration
  def up
    execute("UPDATE communities SET use_domain = redirect_to_domain")
  end

  def down
    execute("UPDATE communities SET redirect_to_domain = use_domain")
    execute("UPDATE communities SET use_domain = NULL")
  end
end
