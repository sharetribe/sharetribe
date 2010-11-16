class AddActiveDaysCountAndLastPageLoadDateToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :active_days_count, :integer, :default => 0
    add_column :people, :last_page_load_date, :datetime
  end

  def self.down
    remove_column :people, :active_days_count
    remove_column :people, :last_page_load_date
  end
end
