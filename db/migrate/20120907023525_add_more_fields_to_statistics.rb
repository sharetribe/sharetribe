class AddMoreFieldsToStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :listings_count, :integer
    add_column :statistics, :new_listings_last_week, :integer
    add_column :statistics, :new_listings_last_month, :integer
    add_column :statistics, :conversations_count, :integer
    add_column :statistics, :new_conversations_last_week, :integer
    add_column :statistics, :new_conversations_last_month, :integer
    add_column :statistics, :messages_count, :integer
    add_column :statistics, :new_messages_last_week, :integer
    add_column :statistics, :new_messages_last_month, :integer
    add_column :statistics, :transactions_count, :integer
    add_column :statistics, :new_transactions_last_week, :integer
    add_column :statistics, :new_transactions_last_month, :integer
    add_column :statistics, :new_users_last_week, :integer
    add_column :statistics, :new_users_last_month, :integer
  end

  def self.down
    remove_column :statistics, :listings_count
    remove_column :statistics, :new_listings_last_week
    remove_column :statistics, :new_listings_last_month
    remove_column :statistics, :conversations_count
    remove_column :statistics, :new_conversations_last_week
    remove_column :statistics, :new_conversations_last_month
    remove_column :statistics, :messages_count
    remove_column :statistics, :new_messages_last_week
    remove_column :statistics, :new_messages_last_month
    remove_column :statistics, :transactions_count
    remove_column :statistics, :new_transactions_last_week
    remove_column :statistics, :new_transactions_last_month
    remove_column :statistics, :new_users_last_week
    remove_column :statistics, :new_users_last_month
  end
end
