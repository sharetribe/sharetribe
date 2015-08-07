class AddVerificationRequestedToSenderEmail < ActiveRecord::Migration
  def change
    add_column :marketplace_sender_emails, :verification_requested_at, :datetime, null: true, after: :verification_status
  end
end
