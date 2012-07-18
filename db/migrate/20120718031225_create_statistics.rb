class CreateStatistics < ActiveRecord::Migration
  def self.up
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
      
    end
  end

  def self.down
    drop_table :statistics
  end
end
