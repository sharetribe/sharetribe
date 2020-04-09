class AddGrowthRatesToStatistics < ActiveRecord::Migration[5.2]
def change
    add_column :statistics, :user_count_weekly_growth, :float
    add_column :statistics, :wau_weekly_growth, :float
  end
end
