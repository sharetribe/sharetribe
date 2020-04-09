class RenamePaypalUsernameToEmail < ActiveRecord::Migration[5.2]
def change
    rename_column :paypal_accounts, :username, :email
  end
end
