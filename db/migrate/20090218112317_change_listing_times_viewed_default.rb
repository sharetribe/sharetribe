class ChangeListingTimesViewedDefault < ActiveRecord::Migration[5.2]
  def self.up
    change_column :listings, :times_viewed, :integer, :default => 0
  end

  def self.down
    change_column :listings, :times_viewed, :integer
  end
end
