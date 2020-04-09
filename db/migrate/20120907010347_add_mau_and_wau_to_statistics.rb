class AddMauAndWauToStatistics < ActiveRecord::Migration[5.2]
def self.up
    add_column :statistics, :mau_g1_count, :integer
    add_column :statistics, :wau_g1_count, :integer
  end

  def self.down
    remove_column :statistics, :mau_g1_count
    remove_column :statistics, :wau_g1_count
  end
end
