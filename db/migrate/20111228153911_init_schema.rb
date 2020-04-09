class InitSchema < ActiveRecord::Migration[5.2]
  def up
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
