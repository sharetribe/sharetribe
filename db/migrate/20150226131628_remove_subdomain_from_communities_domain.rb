class RemoveSubdomainFromCommunitiesDomain < ActiveRecord::Migration[5.2]
  def up
    execute("UPDATE communities SET domain = NULL WHERE INSTR(domain, '.') = 0")
  end

  def down
    execute("UPDATE communities SET domain = ident WHERE domain IS NULL")
  end
end
