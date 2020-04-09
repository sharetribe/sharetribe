class AddSendNotificationsToEmails < ActiveRecord::Migration[5.2]
def change
    add_column :emails, :send_notifications, :boolean
  end
end
