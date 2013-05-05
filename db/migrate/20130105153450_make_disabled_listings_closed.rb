class MakeDisabledListingsClosed < ActiveRecord::Migration
  def up
    # There may be some old listings with visibility "disabled" in the database
    # These were originally items and favors in Sharetribe 1.0 and it's time to migrate them as normal closed listings
    Listing.where("visibility = 'disabled'").each do |l|
      l.update_column(:visibility, "this_community")
      l.update_column(:privacy, "private")
      l.update_column(:open, "false")
    end
  end

  def down
    # there's no way to know which were affected, so do nothing on rollback
  end
end
