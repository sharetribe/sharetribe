class AddAutomaticConfirmationAtToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :automatic_confirmation_at, :datetime, :after => :last_message_at
  end
end
