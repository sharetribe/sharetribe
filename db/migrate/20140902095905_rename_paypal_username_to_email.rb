class RenamePaypalUsernameToEmail < ActiveRecord::Migration
  def change
    rename_column :paypal_accounts, :username, :email
  end
end
