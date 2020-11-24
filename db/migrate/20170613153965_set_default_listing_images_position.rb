class SetDefaultListingImagesPosition < ActiveRecord::Migration[5.1]
  def up
    # MySQL InnoDB by default returns rows in order of primary key, but that behavior is not reliable.
    # Adding extra position column with NULL value broke expected implicit sort order
    ListingImage.where("position IS NULL OR position = 0").update_all("position = id")
  end

  def down; end
end
