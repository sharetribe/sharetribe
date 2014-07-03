class AddSortDateToListing < ActiveRecord::Migration
  def up
    add_column :listings, :sort_date, :datetime, :after => :last_modified

    Listing.update_all("sort_date = created_at")
  end

  def down
    remove_column :listings, :sort_date
  end
end
