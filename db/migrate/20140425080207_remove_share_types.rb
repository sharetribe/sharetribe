class RemoveShareTypes < ActiveRecord::Migration
  def up
    drop_table :share_type_translations
    drop_table :share_types
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
