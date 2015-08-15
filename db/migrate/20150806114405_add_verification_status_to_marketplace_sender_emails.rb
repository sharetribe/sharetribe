class AddVerificationStatusToMarketplaceSenderEmails < ActiveRecord::Migration
  def change
    add_column :marketplace_sender_emails, :verification_status, :string, limit: 32, null: false, after: :email
  end
end
