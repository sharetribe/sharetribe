class AddMauAndWauToStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :mau_g1_count, :integer
    add_column :statistics, :wau_g1_count, :integer
    Statistic.all.each do |s|
      j = JSON.parse(s.extra_data)
      if j["mau_g1"]
        s.mau_g1_count = j["mau_g1"]
      end
      if j["wau_g1"]
        s.wau_g1_count = j["wau_g1"]
      end
      s.save
    end
    
  end

  def self.down
    remove_column :statistics, :mau_g1_count
    remove_column :statistics, :wau_g1_count
  end
end
