class AlterDomainSetupsModifyErrorType < ActiveRecord::Migration[5.2]
  def up
    change_column :domain_setups, :error, :text, default: nil
  end

  def down
    change_column :domain_setups, :error, :string, limit: 255, default: nil
  end
end
