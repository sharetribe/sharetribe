class LovercaseIdents < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Base.connection.execute("UPDATE `communities` SET `ident` = BINARY LOWER(`ident`)")
  end

  def down
  end
end
