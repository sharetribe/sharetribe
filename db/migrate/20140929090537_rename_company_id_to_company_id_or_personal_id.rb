class RenameCompanyIdToCompanyIdOrPersonalId < ActiveRecord::Migration
  def up
    rename_column :checkout_accounts, :company_id, :company_id_or_personal_id
  end

  def down
    rename_column :checkout_accounts, :company_id_or_personal_id, :company_id
  end
end
