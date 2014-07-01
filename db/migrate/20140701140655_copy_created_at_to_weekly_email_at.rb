class CopyCreatedAtToWeeklyEmailAt < ActiveRecord::Migration
  def up
	Listing.update_all("weekly_email_at = created_at")
  end

  def down
  end
end
