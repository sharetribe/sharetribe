class AddWeeklyEmailAtToListings < ActiveRecord::Migration
  def change
    add_column :listings, :updates_email_at, :timestamp, :after => :created_at
  end
end
