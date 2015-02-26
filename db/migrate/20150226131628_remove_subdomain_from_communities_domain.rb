class RemoveSubdomainFromCommunitiesDomain < ActiveRecord::Migration
  def up
    execute("UPDATE communities SET domain = NULL WHERE INSTR(domain, '.') = 0")
  end

  def down
    # Something here? No?
  end
end
