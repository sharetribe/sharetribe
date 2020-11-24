class RemoveStatistics < ActiveRecord::Migration
  def up
    drop_table(:statistics)
  end

  def down
    create_table :statistics do |t|
      t.integer :community_id
      t.timestamps
      t.integer :users_count
      t.float :two_week_content_activation_percentage
      t.float :four_week_transaction_activation_percentage
      t.float :mau_g1
      t.float :wau_g1
      t.float :dau_g1
      t.float :mau_g2
      t.float :wau_g2
      t.float :dau_g2
      t.float :mau_g3
      t.float :wau_g3
      t.float :dau_g3
      t.float :invitations_sent_per_user
      t.float :invitations_accepted_per_user
      t.float :revenue_per_mau_g1
      t.text :extra_data
      t.integer :mau_g1_count
      t.integer :wau_g1_count
      t.integer :listings_count
      t.integer :new_listings_last_week
      t.integer :new_listings_last_month
      t.integer :conversations_count
      t.integer :new_conversations_last_week
      t.integer :new_conversations_last_month
      t.integer :messages_count
      t.integer :new_messages_last_week
      t.integer :new_messages_last_month
      t.integer :transactions_count
      t.integer :new_transactions_last_week
      t.integer :new_transactions_last_month
      t.integer :new_users_last_week
      t.integer :new_users_last_month
      t.float :user_count_weekly_growth
      t.float :wau_weekly_growth
    end
  end
end
