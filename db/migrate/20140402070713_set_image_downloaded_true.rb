class SetImageDownloadedTrue < ActiveRecord::Migration
  def up
    ListingImage.update_all("image_downloaded = 1")
  end

  def down
  end
end
