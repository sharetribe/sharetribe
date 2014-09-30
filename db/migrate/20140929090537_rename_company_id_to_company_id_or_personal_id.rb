class RenameCompanyIdToCompanyIdOrPersonalId < ActiveRecord::Migration
  def change
    rename_column :checkout_accounts, :company_id, :company_id_or_personal_id
  end
end
