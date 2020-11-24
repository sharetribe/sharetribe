class RemoveTransactionColumnsFromConversation < ActiveRecord::Migration
  def up
    remove_column :conversations, :type, :automatic_confirmation_after_days
  end

  def down
    add_column :conversations, :type, :string, after: :id
    add_column :conversations, :automatic_confirmation_after_days, :integer, after: :last_message_at
  end
end
