class AddAutomaticConfirmationTimeToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :automatic_confirmation_time, :datetime, :after => :last_message_at
  end
end
