class AddSendNotificationsToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :send_notifications, :boolean
  end
end
