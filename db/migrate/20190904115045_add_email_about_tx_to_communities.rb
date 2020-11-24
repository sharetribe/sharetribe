class AddEmailAboutTxToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :email_admins_about_new_transactions, :boolean, default: false
  end
end
